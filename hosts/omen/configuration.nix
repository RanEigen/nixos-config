{ my, ... }:
{
  imports = [
    ../../profiles/desktop.nix # 桌面与系统基础
    ../../profiles/development.nix # 开发与容器工具
  ];
  home-manager.users.${my.username}.imports = [ ./hm.nix ];
}
