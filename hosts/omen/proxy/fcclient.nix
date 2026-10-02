# 仅声明本机集成，不安装私有包、不提权、不写入共享配置。
{
  config,
  lib,
  my,
  ...
}:
let
  backend = import ./settings.nix;
in
{
  assertions = [
    {
      assertion = config.networking.hostName == "omen";
      message = "此私有客户端集成仅用于 OMEN；请从主机 imports 移除 hosts/omen/proxy/fcclient.nix。";
    }
  ];
  omen.proxy.bypassProcesses = lib.mkBefore [
    "fcclient"
    "fcclientCore"
  ];
  home-manager.users.${my.username} = {
    # 声明式会话变量，防止 fish universal 残留（REF:2026-09-09-fish-abbr-universal-residue）。
    home.sessionVariables.fcproxy_port = toString backend.port;
    programs.noctalia.settings.widget.tray = {
      hide_passive = false; # 此客户端上报 Passive，默认过滤会隐藏托盘。
      pinned = lib.mkAfter [ "com.fcclient.app" ];
    };
  };
}
