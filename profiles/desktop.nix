{ inputs, my, ... }:
{
  imports = [
    ./base.nix # 桌面依赖系统基础
    inputs.catppuccin.nixosModules.catppuccin # 系统主题接口
    inputs.noctalia.nixosModules.default # 桌面壳接口
    inputs.noctalia-greeter.nixosModules.default # 登录界面接口
    inputs.umbriel.nixosModules.default # 合成器接口
    ../modules/desktop.nix # 会话、认证与 portal
    ../modules/desktop-packages.nix # 会话依赖与字体
    ../modules/input-method.nix # 输入法与会话变量
    ../modules/services.nix # 音频与桌面辅助服务
    ../modules/theme.nix # 系统配色
  ];

  home-manager.users.${my.username}.imports = [
    inputs.catppuccin.homeModules.catppuccin # 用户主题接口
    inputs.umbriel.homeModules.default # 合成器接口
    ../home/modules/env.nix # 桌面会话环境
    ../home/modules/theme # 外观与配色
    ../home/modules/desktop # 桌面应用
  ];
}
