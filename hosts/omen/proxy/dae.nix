# 透明代理只属于本机；国内直连，其他流量进入本地 SOCKS 后端。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  backend = import ./settings.nix;
  processes = config.omen.proxy.bypassProcesses;
in
{
  # 客户端可独立贡献进程匹配；移除模块时规则一并消失。
  options.omen.proxy.bypassProcesses = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "本机透明代理必须直连的进程名";
  };
  config = {
    assertions = [
      {
        assertion = config.networking.hostName == "omen";
        message = "此网络方案仅用于 OMEN；请移除 hosts/omen/proxy 并配置目标机网络。";
      }
    ];
    omen.proxy.bypassProcesses = [
      "sshd"
      "systemd-resolved"
      "openvpn"
      "wireguard"
      "wg-quick"
      "tailscaled"
      "tailscale"
      "zerotier-one"
      "chronyd"
      "ntpd"
      "syncthing"
    ];
    services.dae = {
      enable = true;
      package = pkgs.dae;
      assets = [
        pkgs.v2ray-geoip
        pkgs.v2ray-domain-list-community
      ];
      disableTxChecksumIpGeneric = false;
      openFirewall = {
        enable = true;
        port = 12345;
      };
      config = ''
        global {
          lan_interface: auto
          wan_interface: auto
          log_level: info
          allow_insecure: true
          auto_config_kernel_parameter: true
        }
        node {
          local_backend: 'socks5://${backend.address}:${toString backend.port}'
        }
        group {
          proxy {
            filter: name(local_backend)
            policy: fixed(0)
          }
        }
        dns {
          optimistic_cache: false
          max_cache_size: 4096
          upstream {
            alidns: 'udp://223.5.5.5:53'
            googledns: 'tcp://8.8.8.8:53'
          }
          routing {
            request {
              fallback: alidns
            }
          }
        }
        routing {
          pname(${lib.concatStringsSep ", " processes}) -> direct
          dip(geoip:private) -> direct
          dip(geoip:cn) -> direct
          domain(geosite:cn) -> direct
          fallback: proxy
        }
      '';
    };
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    # 仅允许 dae 虚拟接口访问后端，不对局域网开放监听端口。
    networking.firewall.interfaces.${backend.interface} = {
      allowedTCPPorts = [ backend.port ];
      allowedUDPPorts = [ backend.port ];
    };
    systemd.services.dae-host-addr = {
      description = "Assign stable host address to dae backend interface";
      wantedBy = [ "dae.service" ];
      after = [ "dae.service" ];
      partOf = [ "dae.service" ];
      path = [
        pkgs.iproute2
        pkgs.gnugrep
        pkgs.coreutils
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "dae-host-addr" ''
          set -e
          i=0
          until ip link show dev ${backend.interface} >/dev/null 2>&1; do
            i=$((i+1))
            [ "$i" -ge 40 ] && exit 1
            sleep 0.5
          done
          ip addr show dev ${backend.interface} | grep -Fq ${lib.escapeShellArg backend.address} || \
            ip addr add ${backend.address}/${toString backend.prefixLength} dev ${backend.interface}
        '';
      };
    };
  };
}
