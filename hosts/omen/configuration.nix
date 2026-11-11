{ userConfig, ... }:
{
  imports = [
    ../../profiles/desktop.nix # 桌面与系统基础
    ../../profiles/development.nix # 开发与容器工具
  ];
  home-manager.users.${userConfig.user.userName}.imports = [ ./hm.nix ];
}
