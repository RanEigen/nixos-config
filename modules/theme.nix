# 系统输入法配色；引导器主题由主机选择。
{ userConfig, ... }:

{
  catppuccin = {
    enable = true;
    autoEnable = true; # 显式声明，避免上游 autoEnable 迁移警告（STANDARDS §8）
    inherit (userConfig.preferences.catppuccin) flavor accent;

    # Catppuccin 二进制缓存（catppuccin.cachix.org）：主题包免本地构建
    cache.enable = true;

    # fcitx5：安装主题 addon；/etc/xdg 的主题名会被用户配置遮蔽，
    # 故用户层 classicui.conf 显式给出同名主题（见 home/modules/desktop/fcitx5.nix）
    fcitx5.enable = true;

  };
}
