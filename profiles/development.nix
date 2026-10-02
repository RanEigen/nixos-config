{ inputs, my, ... }:
{
  imports = [
    ./base.nix # 开发环境依赖系统基础
    ../modules/virtualisation.nix # 容器与 AppImage
  ];

  home-manager.users.${my.username}.imports = [
    inputs.nixvim.homeModules.nixvim # Neovim 配置接口
    ../home/modules/tools/dev.nix # Git、direnv 与密钥工具
    ../home/modules/tools/vscode.nix # VSCode
    ../home/modules/tools/zed.nix # Zed
    ../home/modules/tools/nixvim.nix # Neovim
  ];
}
