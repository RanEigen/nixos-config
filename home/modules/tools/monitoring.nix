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
  # 接管首次运行生成的配置，避免 HM 链接冲突。
  xdg.configFile."btop/btop.conf".force = true;
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
