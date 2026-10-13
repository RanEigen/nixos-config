#!/usr/bin/env python3
"""NUT75 HID class probe; Python stdlib + libusb-1.0, no vendor requests.

Default: GET_PROTOCOL only, without detaching any driver.
--exercise --ack-temporary-input-loss: temporarily detach ONLY the selected
NUT75 interface, capture report/boot/report input, restore Report Protocol and
reattach usbhid. Use the built-in keyboard to launch/interrupt this program.
--led is opt-in, Interface 1 only, and requires readable original LED state.
No USB reset, SET_CONFIGURATION, firmware writes, or vendor commands.
"""
import argparse
import ctypes as C
import ctypes.util
import glob
from pathlib import Path
import signal
import sys
import time


def log(message):
    print(f"{time.monotonic():.6f} {message}", flush=True)


class USBError(RuntimeError):
    pass


class LibUSB:
    def __init__(self, override):
        candidates = [override] if override else [
            ctypes.util.find_library("usb-1.0"), "libusb-1.0.so.0",
            *sorted(glob.glob('/nix/store/*-libusb-*/lib/libusb-1.0.so.0')),
        ]
        for name in filter(None, candidates):
            try:
                self.lib = C.CDLL(name)
                break
            except OSError:
                continue
        else:
            raise USBError("libusb-1.0 not found; use --libusb /absolute/path/libusb-1.0.so.0")
        ptr = C.c_void_p
        u8, u16, uint, integer = C.c_uint8, C.c_uint16, C.c_uint, C.c_int
        self.init = self.bind('libusb_init', integer, [C.POINTER(ptr)])
        self.exit = self.bind('libusb_exit', None, [ptr])
        self.get_list = self.bind('libusb_get_device_list', C.c_ssize_t, [ptr, C.POINTER(C.POINTER(ptr))])
        self.free_list = self.bind('libusb_free_device_list', None, [C.POINTER(ptr), integer])
        self.bus = self.bind('libusb_get_bus_number', u8, [ptr])
        self.address = self.bind('libusb_get_device_address', u8, [ptr])
        self.open = self.bind('libusb_open', integer, [ptr, C.POINTER(ptr)])
        self.close = self.bind('libusb_close', None, [ptr])
        self.active = self.bind('libusb_kernel_driver_active', integer, [ptr, integer])
        self.detach = self.bind('libusb_detach_kernel_driver', integer, [ptr, integer])
        self.attach = self.bind('libusb_attach_kernel_driver', integer, [ptr, integer])
        self.claim = self.bind('libusb_claim_interface', integer, [ptr, integer])
        self.release = self.bind('libusb_release_interface', integer, [ptr, integer])
        self.control = self.bind('libusb_control_transfer', integer,
                                 [ptr, u8, u8, u16, u16, ptr, u16, uint])
        self.interrupt = self.bind('libusb_interrupt_transfer', integer,
                                   [ptr, u8, ptr, integer, C.POINTER(integer), uint])
        self.error_name = self.bind('libusb_error_name', C.c_char_p, [integer])

    def bind(self, name, result, args):
        fn = getattr(self.lib, name)
        fn.restype, fn.argtypes = result, args
        return fn

    def error(self, rc):
        return f"{rc} {self.error_name(rc).decode()}"

    def check(self, rc, action):
        if rc < 0:
            raise USBError(f"{action}: {self.error(rc)}")
        return rc


def find_device(path):
    devices = []
    for p in Path('/sys/bus/usb/devices').iterdir():
        try:
            if (p/'idVendor').read_text().strip() == '0c45' and (p/'idProduct').read_text().strip() == '880c':
                devices.append(p)
        except OSError:
            continue
    if path:
        devices = [p for p in devices if p.name == path]
    if len(devices) != 1:
        raise USBError(f"Expected one NUT75; found {[p.name for p in devices]}; select --sysfs NAME")
    return devices[0]


def run(args):
    p = find_device(args.sysfs)
    intf = args.interface
    configuration = (p/'bConfigurationValue').read_text().strip()
    if configuration != '1':
        raise USBError('Expected active configuration 1; refusing to reconfigure the device')
    q = Path(f"{p}:1.{intf}")
    # Restrict the script to the two known boot interfaces and verified endpoints.
    desc = (p/'descriptors').read_bytes()
    current, endpoints, protocols = None, {}, {}
    offset = 0
    while offset < len(desc):
        length = desc[offset]
        if length < 2 or offset + length > len(desc):
            raise USBError("Malformed sysfs configuration descriptors")
        d = desc[offset:offset+length]
        if d[1] == 4:
            current = d[2]
            protocols[current] = tuple(d[5:8])
        elif d[1] == 5 and current == intf and d[2] & 0x80 and d[3] & 3 == 3:
            endpoints[d[2]] = int.from_bytes(d[4:6], 'little') & 0x7ff
        offset += length
    ep = 0x81 + intf
    expected = (3, 1, 2 if intf == 0 else 1)
    if protocols.get(intf) != expected or ep not in endpoints:
        raise USBError("Interface layout differs from investigated NUT75; refusing requests")
    packet_size = endpoints[ep]
    bus, address = int((p/'busnum').read_text()), int((p/'devnum').read_text())
    log(f"target={p.name} VID:PID=0c45:880c bcdDevice={(p/'bcdDevice').read_text().strip()} "
        f"bus={bus} address={address} speed={(p/'speed').read_text().strip()}Mbps "
        f"interface={intf} endpoint=0x{ep:02x} maxpacket={packet_size}")
    log(f"initial driver={q.joinpath('driver').resolve() if q.joinpath('driver').exists() else 'none'}")
    usb = LibUSB(args.libusb)
    context, handle, listing = C.c_void_p(), C.c_void_p(), C.POINTER(C.c_void_p)()
    usb.check(usb.init(C.byref(context)), 'libusb_init')
    detached = claimed = False
    changed = False
    idle_state = {}
    cleanup_failed = False

    def control(rt, request, value, length=0, payload=None):
        data = C.create_string_buffer(max(1, length))
        if payload is not None:
            if len(payload) != length:
                raise ValueError("payload length mismatch")
            C.memmove(data, payload, length)
        log(f"CONTROL bmRequestType=0x{rt:02x} bRequest=0x{request:02x} "
            f"wValue=0x{value:04x} wIndex=0x{intf:04x} wLength={length} "
            f"OUT={payload.hex(' ') if payload is not None else '-'}")
        rc = usb.control(handle, rt, request, value, intf, data, length, 1000)
        if rc < 0:
            log(f"ERROR {usb.error(rc)}")
            return None
        result = data.raw[:rc]
        log(f"RESPONSE length={rc} IN={result.hex(' ') if rt & 0x80 else '-'}")
        if rc != length:
            log(f"MALFORMED/SHORT: expected {length} transferred bytes")
            return None
        return result

    def get_protocol():
        value = control(0xa1, 0x03, 0, 1)
        if value is not None:
            log(f"GET_PROTOCOL={value[0]} ({ {0: 'BOOT', 1: 'REPORT'}.get(value[0], 'INVALID') })")
        return value

    def set_protocol(value):
        nonlocal changed
        changed = True  # Even a timed-out request could have changed device state.
        result = control(0x21, 0x0b, value)
        observed = get_protocol()
        if observed != bytes([value]):
            log("WARNING: protocol readback absent or inconsistent; inspect raw input regardless")
        return result

    def capture(label):
        log(f"CAPTURE {label}: for {args.seconds}s tap/release A, Up, Enter, then Shift+A; "
            "Interface 0 capture may duplicate ordinary input via Interface 1. Do not type secrets.")
        deadline = time.monotonic() + args.seconds
        data, count = C.create_string_buffer(packet_size), C.c_int()
        packets = timeouts = 0
        while time.monotonic() < deadline:
            rc = usb.interrupt(handle, ep, data, packet_size, C.byref(count), 200)
            if count.value:
                raw = data.raw[:count.value]
                log(f"INT ep=0x{ep:02x} actual_length={len(raw)} data={raw.hex(' ')} rc={rc}")
                packets += 1
            if rc == -7:  # LIBUSB_ERROR_TIMEOUT: NAK/idle is not evidence of broken protocol.
                timeouts += 1
            elif rc < 0:
                log(f"INT ERROR {usb.error(rc)}")
                break
        log(f"CAPTURE DONE packets={packets} timeouts={timeouts}; "
            "zero packets without a confirmed keypress is inconclusive")

    def snapshot(protocol):
        # GET_REPORT Input: report 0 in boot, report 2 in Interface 1 report mode.
        rid = 2 if protocol == 1 and intf == 1 else 0
        size = 16 if rid == 2 else (8 if intf == 1 or protocol == 1 else 3)
        control(0xa1, 0x01, 0x0100 | rid, size)

    def led_test():
        original = control(0xa1, 0x01, 0x0200, 1)
        if original is None:
            log("LED test skipped: original output report unavailable; no blind LED write")
            return
        try:
            control(0x21, 0x09, 0x0200, 1, bytes([original[0] ^ 2]))
            time.sleep(1)
            control(0xa1, 0x01, 0x0200, 1)
        finally:
            control(0x21, 0x09, 0x0200, 1, original)

    try:
        n = usb.check(usb.get_list(context, C.byref(listing)), 'get_device_list')
        for i in range(n):
            device = listing[i]
            if usb.bus(device) == bus and usb.address(device) == address:
                usb.check(usb.open(device, C.byref(handle)), 'open NUT75')
                break
        if not handle.value:
            raise USBError("Device disappeared before open")
        if not args.exercise:
            result = get_protocol()
            if result is None:
                raise USBError("GET_PROTOCOL inconclusive; BUSY may be host usbhid ownership, "
                               "not a device STALL. Exercise requires explicit detach opt-in.")
            return
        log("Temporarily releasing only the selected external NUT75 interface")
        active = usb.check(usb.active(handle, intf), 'kernel_driver_active')
        if active:
            usb.check(usb.detach(handle, intf), 'detach selected interface')
            detached = True
        usb.check(usb.claim(handle, intf), 'claim selected interface')
        claimed = True
        initial = get_protocol()
        log(f"Initial protocol (after Linux init, NOT power-on default): {initial}")
        for rid in ([0] if intf == 0 else [1, 2, 3, 4]):
            value = control(0xa1, 0x02, rid, 1)
            if value is not None:
                idle_state[rid] = value[0]
        # Establish interrupt input before any GET_REPORT: this request STALLs
        # on the investigated firmware and must not contaminate the baseline.
        set_protocol(1)
        capture('REPORT baseline (before GET_REPORT)')
        set_protocol(0)
        capture('BOOT without changing idle (before GET_REPORT)')
        for idle in [0, 125]:  # 0=change only; 125*4ms=500ms.
            control(0x21, 0x0a, idle << 8)
            control(0xa1, 0x02, 0, 1)
            capture(f'BOOT idle={idle} ({idle * 4}ms; zero=change only)')
        set_protocol(1)
        capture('REPORT after BOOT (recovery; before GET_REPORT)')
        # Keep every input window ahead of GET_REPORT, including recovery.
        snapshot(1)
        set_protocol(0)
        snapshot(0)
        if args.led:
            led_test()
    finally:
        # Best effort, not a guarantee against disconnect, SIGKILL or a wedged MCU.
        if handle.value:
            if changed:
                log("RESTORE Report Protocol before usbhid reattach (Linux expects report format)")
                if control(0x21, 0x0b, 1) is None:
                    cleanup_failed = True
                for rid, idle in idle_state.items():
                    if control(0x21, 0x0a, (idle << 8) | rid) is None:
                        cleanup_failed = True
                get_protocol()
            if claimed:
                rc = usb.release(handle, intf)
                log(f"release_interface: {rc} {usb.error(rc) if rc < 0 else 'OK'}")
                cleanup_failed |= rc < 0
            if detached:
                rc = usb.attach(handle, intf)
                log(f"reattach_kernel_driver: {rc} {usb.error(rc) if rc < 0 else 'OK'}")
                cleanup_failed |= rc < 0
            usb.close(handle)
        if listing:
            usb.free_list(listing, 1)
        usb.exit(context)
        if cleanup_failed:
            log("WARNING cleanup incomplete: unplug/replug only NUT75 using built-in keyboard; "
                "if necessary bind its verified interface to usbhid manually")
    log("Completed. No automatic conformance verdict: inspect keypress captures and control errors.")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--sysfs', help='USB device name, e.g. 1-1 (not interface name)')
    parser.add_argument('--interface', type=int, choices=[0, 1], default=1)
    parser.add_argument('--libusb', help='explicit shared library path')
    parser.add_argument('--exercise', action='store_true', help='temporarily detach and test report/boot/report')
    parser.add_argument('--ack-temporary-input-loss', action='store_true')
    parser.add_argument('--seconds', type=float, default=8, help='each capture window, 1..30 seconds')
    parser.add_argument('--led', action='store_true', help='opt-in Boot Keyboard LED output test')
    args = parser.parse_args()
    if not 1 <= args.seconds <= 30:
        parser.error('--seconds must be in [1,30]')
    if args.exercise and not args.ack_temporary_input_loss:
        parser.error('--exercise requires --ack-temporary-input-loss; use the built-in keyboard')
    if args.led and (not args.exercise or args.interface != 1):
        parser.error('--led requires --exercise --interface 1')
    signal.signal(signal.SIGTERM, lambda *_: (_ for _ in ()).throw(KeyboardInterrupt()))
    try:
        run(args)
    except (USBError, OSError) as error:
        log(f"FAILED: {error}")
        return 1
    except KeyboardInterrupt:
        log("Interrupted; cleanup attempted. If NUT75 is unavailable, unplug/replug it.")
        return 130
    return 0


if __name__ == '__main__':
    sys.exit(main())
