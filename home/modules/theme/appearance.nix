# 字体渲染、GTK / Qt、图标与光标。
{ pkgs, my, ... }:
let
  # 保留 Papirus 图标，按主题继承链回退到 Tela。
  papirusWithTelaFallback = pkgs.runCommand "papirus-icon-theme-with-tela-fallback" { } ''
    mkdir -p $out/share/icons
    for t in Papirus Papirus-Dark Papirus-Light; do
      case $t in
        Papirus) fb=Tela-circle ;;
        Papirus-Dark) fb=Tela-circle-dark ;;
        Papirus-Light) fb=Tela-circle-light ;;
      esac
      mkdir -p $out/share/icons/$t
      ln -s ${pkgs.papirus-icon-theme}/share/icons/$t/* $out/share/icons/$t/
      rm $out/share/icons/$t/index.theme
      cp ${pkgs.papirus-icon-theme}/share/icons/$t/index.theme $out/share/icons/$t/index.theme
      sed -i "s|^Inherits=.*|Inherits=$fb,hicolor|" $out/share/icons/$t/index.theme
    done
    for t in Tela-circle Tela-circle-dark Tela-circle-light; do
      ln -s ${pkgs.tela-circle-icon-theme}/share/icons/$t $out/share/icons/$t
    done
    ln -s ${pkgs.papirus-icon-theme}/share/icons/hicolor $out/share/icons/hicolor
  '';
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    accents = [ my.catppuccin.accent ];
    variant = my.catppuccin.flavor;
  };
in
{
  xdg.configFile = {
    "fontconfig/fonts.conf" = {
      source = ../../../assets/fonts.conf;
      force = true;
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
      name = "Papirus-Dark";
      package = papirusWithTelaFallback;
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
    size = 30;
  };
}
