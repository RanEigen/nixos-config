# 客户端订阅和监听设置由 GUI 管理；后端约定见 settings.nix。
{ my, pkgs, ... }:
{
  # nixpkgs 将 mihomo 作为 verge-mihomo 提供；核心出站不能再次进入 dae。
  omen.proxy.bypassProcesses = [
    "clash-verge"
    "verge-mihomo"
    "mihomo"
  ];
  home-manager.users.${my.username} = {
    home.packages = [ pkgs.clash-verge-rev ];
    programs.noctalia.settings.widget.tray.pinned = [ "tray-icon tray app clash-verge-rev-tray" ];
  };
}
