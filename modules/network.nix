# NetworkManager、防火墙与 TCP 策略。
{ my, ... }:
{
  networking = {
    hostName = my.hostname;
    inherit (my) hostId;
    networkmanager.enable = true;
    firewall.enable = true;
  };
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
