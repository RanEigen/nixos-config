{ pkgs, ... }:
{
  home.packages = [ pkgs.qq ];
  xdg.configFile."qq-flags.conf" = {
    text = ''
      --ozone-platform=wayland
    '';
  };
}
