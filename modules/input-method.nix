# 系统会话与合成器均需设置 IM 变量（REF:2026-08-21-fcitx5-gtk）。
{ pkgs, lib, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      # Rime 必须同时提供 schema 数据。
      (fcitx5-rime.override {
        rimeDataPkgs = [
          pkgs.rime-data
          pkgs.rime-ice
        ];
      })
      rime-ice
      fcitx5-gtk
      qt6Packages.fcitx5-chinese-addons
    ];
  };
  environment.sessionVariables = {
    QT_IM_MODULES = "wayland;fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus"; # kitty 使用 fcitx5 的 ibus 兼容接口。
  };
  # GTK3/4 使用 text-input-v3，覆盖上游自动注入（REF:2026-08-21-fcitx5-gtk）。
  environment.variables.GTK_IM_MODULE = lib.mkForce "";
}
