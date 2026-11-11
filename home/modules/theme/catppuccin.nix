# 自动为已启用应用设置主题；仅列出例外。
{ userConfig, ... }:
{
  catppuccin = {
    enable = true;
    autoEnable = true;
    inherit (userConfig.preferences.catppuccin) flavor accent;
    cursors.enable = true; # 光标端口不随 autoEnable。
    gtk.icon.enable = false; # 使用原版 Papirus-Dark。
    nvim.enable = false; # 由 Nixvim 配色模块管理。
    firefox.enable = false; # 浏览器仅包安装，没有 HM profile。
    kvantum.enable = false; # Qt 使用 GTK 平台主题。
  };
}
