# NetworkManager、防火墙与 TCP 策略。
{ hostConfig, ... }:
{
  networking = {
    hostName = hostConfig.hostName;
    inherit (hostConfig) hostId;
    networkmanager.enable = true;
    firewall.enable = true;
  };
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
