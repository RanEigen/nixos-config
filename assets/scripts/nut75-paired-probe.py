#!/usr/bin/env python3
"""Paired NUT75 interrupt probe; explicit temporary-input-loss acknowledgement.

Use the built-in keyboard and save work before running this diagnostic as root.
Only HID class requests, no vendor commands, firmware writes or USB reset.
GET_REPORT is deliberately postponed until after all interrupt input windows.
"""
import ctypes as C
import importlib.util
import os
from pathlib import Path
import select
import signal
import sys
import threading
import time
from collections import Counter

if '--ack-temporary-input-loss' not in sys.argv:
 raise SystemExit('Requires --ack-temporary-input-loss; use the built-in keyboard. No USB access performed.')
spec=importlib.util.spec_from_file_location('probe',Path(__file__).with_name('nut75-hid-probe.py'))
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
p=m.find_device(None)
if (p/'product').read_text().strip()!='NUT75' or (p/'bConfigurationValue').read_text().strip()!='1':
 raise SystemExit('Unexpected device/configuration; refusing requests.')
for i,pr,size in [(0,'02',8),(1,'01',16)]:
 q=Path(f'{p}:1.{i}')
 if [(q/k).read_text().strip() for k in ['bInterfaceClass','bInterfaceSubClass','bInterfaceProtocol']]!=['03','01',pr]:
  raise SystemExit('Boot interface layout changed; refusing requests.')
 if int((q/f'ep_{0x81+i:02x}'/'wMaxPacketSize').read_text(),16)!=size:
  raise SystemExit('Endpoint size changed; refusing requests.')
bus=int((p/'busnum').read_text());address=int((p/'devnum').read_text())
usb=m.LibUSB(None);context=C.c_void_p();handle=C.c_void_p();listing=C.POINTER(C.c_void_p)()
lock=threading.Lock();claimed=[];detached=[];initial={};idle={};change=False;monfd=None;monstop=threading.Event()
def log(s):
 with lock:print(f'{time.monotonic():.6f} {s}',flush=True)
def ctrl(i,rt,req,value,length=0,payload=None):
 data=C.create_string_buffer(max(1,length))
 if payload is not None:C.memmove(data,payload,length)
 log(f'CONTROL bmRequestType={rt:02x} bRequest={req:02x} wValue={value:04x} wIndex={i:04x} wLength={length} OUT={payload.hex(" ") if payload else "-"}')
 rc=usb.control(handle,rt,req,value,i,data,length,1000)
 raw=data.raw[:max(0,rc)]
 log(f'RESPONSE rc={rc} result={usb.error(rc) if rc<0 else "OK"} IN={raw.hex(" ") if rt&128 else "-"}')
 return raw if rc==length else None
def read_protocols(label):
 states={i:ctrl(i,0xa1,3,0,1) for i in [0,1]};log(f'PROTOCOLS {label} {states}');return states
def protocol(i,value):
 global change
 change=True;ctrl(i,0x21,0x0b,value)
def monitor():
 pending=b'';tags={};redact=set();marker=f':{bus}:{address:03d}:'.encode()
 while not monstop.is_set():
  if not select.select([monfd],[],[],0.1)[0]:continue
  try:chunk=os.read(monfd,65536)
  except BlockingIOError:continue
  pending+=chunk
  while b'\n' in pending:
   line,pending=pending.split(b'\n',1)
   if marker not in line:continue
   fields=line.decode(errors='replace').split()
   if len(fields)<6:continue
   # Retain all control transactions and successful non-empty interrupt input;
   # suppress timeout-driven cancellation chatter, not successful reports.
   if fields[3].startswith('I') and not (fields[2]=='C' and fields[4].split(':')[0]=='0' and int(fields[5])>0):continue
   urb=fields[0]
   if fields[2]=='S' and ' s 80 06 0303 ' in ' '+line.decode(errors='replace')+' ':redact.add(urb)
   if fields[2]=='C' and urb in redact:
    fields=fields[:6]+['[serial payload redacted]'];redact.discard(urb)
   fields[0]=tags.setdefault(urb,f'urb{len(tags)+1:04d}')
   log('USBMON '+' '.join(fields))
def capture(label,seconds):
 log(f'PAIRED CAPTURE {label} duration={seconds}s; tap/release A, Up, Enter, Shift+A on NUT75. No GET_REPORT sent before/during these captures.')
 stop=threading.Event();counts=Counter();threads=[]
 def reader(i):
  ep=0x81+i;size=8 if i==0 else 16;data=C.create_string_buffer(size);count=C.c_int()
  while not stop.is_set():
   count.value=0
   rc=usb.interrupt(handle,ep,data,size,C.byref(count),500)
   if count.value:
    counts[i]+=1;log(f'INT interface={i} ep={ep:02x} actual_length={count.value} rc={rc} data={data.raw[:count.value].hex(" ")}')
   if rc<0 and rc!=-7:log(f'INT ERROR interface={i} {usb.error(rc)}');break
 for i in [0,1]:
  t=threading.Thread(target=reader,args=(i,),daemon=True);t.start();threads.append(t)
 try:time.sleep(seconds)
 finally:
  stop.set()
  for t in threads:t.join(timeout=2)
 log(f'PAIRED CAPTURE END {label} packets={dict(counts)}')

def interrupted(*_):raise KeyboardInterrupt()
signal.signal(signal.SIGTERM,interrupted)
usb.check(usb.init(C.byref(context)),'init')
hostled=0
led_known=False
for led in Path('/sys/class/leds').iterdir():
 if f'/{p.name}:1.0/' not in str(led.resolve()):continue
 for bit,name in [(0,'numlock'),(1,'capslock'),(2,'scrolllock')]:
  if led.name.endswith('::'+name):
   led_known=True
   if int((led/'brightness').read_text())>0:hostled|=1<<bit
log(f'HOST_LED known={led_known} bitmap_before_detach={hostled:02x}')
try:
 monfd=os.open(f'/sys/kernel/debug/usb/usbmon/{bus}u',os.O_RDONLY|os.O_NONBLOCK)
 mt=threading.Thread(target=monitor,daemon=True);mt.start()
 n=usb.check(usb.get_list(context,C.byref(listing)),'list')
 for j in range(n):
  if usb.bus(listing[j])==bus and usb.address(listing[j])==address:
   usb.check(usb.open(listing[j],C.byref(handle)),'open');break
 if not handle.value:raise RuntimeError('device disappeared')
 log(f'TARGET {p.name} 0c45:880c speed={(p/"speed").read_text().strip()}')
 for i in [0,1]:
  if usb.active(handle,i)==1:
   usb.check(usb.detach(handle,i),f'detach {i}');detached.append(i)
  usb.check(usb.claim(handle,i),f'claim {i}');claimed.append(i)
 initial=read_protocols('initial')
 for i,rids in [(0,[0]),(1,[1,2,3,4])]:
  for rid in rids:
   value=ctrl(i,0xa1,2,rid,1)
   if value is not None:idle[(i,rid)]=value[0]
 capture('initial state / no SET_PROTOCOL / no GET_REPORT',10)
 protocol(0,1);protocol(1,1);read_protocols('both Report')
 capture('both Report / no GET_REPORT',15)
 protocol(1,0);read_protocols('Interface 1 Boot; Interface 0 should remain Report')
 capture('Interface 1 Boot / Interface 0 Report',15)
 protocol(0,0);read_protocols('both Boot')
 capture('both Boot',10)
 for i in [0,1]:ctrl(i,0x21,0x0a,0x7d00)
 capture('both Boot / idle 500ms',5)
 # Known HID Boot Keyboard LED output, all LEDs off. Host LED state is recorded
 # and restored through Interface 0 Report output. Not an unknown vendor command.
 log(f'HOST_LED saved_bitmap={hostled:02x}; test uses same bitmap, no key state change')
 if led_known:ctrl(1,0x21,9,0x0200,1,bytes([hostled]))
 else:log('LED write skipped: host LED state unavailable')
 # GET_REPORT probes are deliberately at the END, after every input capture.
 ctrl(1,0xa1,1,0x0100,8)
 protocol(0,1);protocol(1,1);read_protocols('both Report restored before GET_REPORT')
 if led_known:ctrl(0,0x21,9,0x0200,1,bytes([hostled]))
 ctrl(0,0xa1,1,0x0100,8)
 ctrl(1,0xa1,1,0x0102,16)
finally:
 if handle.value:
  if change:
   for i in claimed:ctrl(i,0x21,0x0b,1)
   for (i,rid),value in idle.items():ctrl(i,0x21,0x0a,(value<<8)|rid)
   read_protocols('cleanup')
  for i in reversed(claimed):
   rc=usb.release(handle,i);log(f'RELEASE interface={i} rc={rc}')
  for i in detached:
   rc=usb.attach(handle,i);log(f'REATTACH interface={i} rc={rc}')
  usb.close(handle)
 if listing:usb.free_list(listing,1)
 usb.exit(context)
 if monfd is not None:
  time.sleep(0.2);monstop.set();mt.join(timeout=2);os.close(monfd)
 log('Cleanup attempted; if any reattach error, unplug/replug only NUT75.')
