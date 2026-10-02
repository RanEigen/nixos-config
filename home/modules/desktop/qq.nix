{ pkgs, ... }:
{
  home.packages = [ pkgs.qq ];
  xdg.configFile."qq-flags.conf" = {
    force = true;
    text = ''
      --ozone-platform=wayland
    '';
  };
}
