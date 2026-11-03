# 字体渲染、GTK / Qt、图标与光标。
{ pkgs, my, ... }:
let
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    accents = [ my.catppuccin.accent ];
    variant = my.catppuccin.flavor;
  };
in
{
  xdg.configFile = {
    "fontconfig/fonts.conf" = {
      source = ../../../assets/fonts.conf;
    };
    # libadwaita 不读取 gtk-theme-name，通过 CSS 注入主题。
    "gtk-4.0/gtk.css".source =
      "${catppuccinGtk}/share/themes/${my.catppuccin.names.gtk}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${catppuccinGtk}/share/themes/${my.catppuccin.names.gtk}/gtk-4.0/gtk-dark.css";
    "gtk-4.0/assets" = {
      source = "${catppuccinGtk}/share/themes/${my.catppuccin.names.gtk}/gtk-4.0/assets";
      recursive = true;
    };
  };
  gtk = {
    enable = true;
    gtk4.theme = null;
    theme = {
      name = my.catppuccin.names.gtk;
      package = catppuccinGtk;
    };
    iconTheme = {
      name = my.desktop.iconTheme;
      package = pkgs.papirus-icon-theme;
    };
    # GTK3/4 不写 im-module；GTK2 仅用于 X11（REF:2026-08-21-fcitx5-gtk）。
    gtk2.extraConfig = "gtk-im-module=\"fcitx\"";
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    size = my.desktop.cursorSize;
  };
}
