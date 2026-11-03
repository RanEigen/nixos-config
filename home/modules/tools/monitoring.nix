# 终端监控与排障工具。
{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      vim_keys = false;
      update_ms = 2000;
      graph_symbol = "block";
      shown_boxes = "cpu mem net proc";
    };
  };
  programs.cava = {
    enable = true;
    settings.general = {
      framerate = 60;
      bars = 20;
      autosens = 1;
      lower_cutoff_freq = 50;
    };
  };
  home.packages = with pkgs; [
    procs
    duf
    dust
    dua
    lnav
    bandwhich
    gping
  ];
}
