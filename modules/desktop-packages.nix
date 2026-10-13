# greeter / 会话共用依赖及字体。
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    cups-pk-helper
    pulseaudio # pactl，用于 PipeWire 排障。
    alsa-utils
  ];
  fonts.packages = with pkgs; [
    maple-mono.NF-CN
    nerd-fonts.jetbrains-mono
    lxgw-neoxihei
    noto-fonts-cjk-sans
    noto-fonts
    noto-fonts-color-emoji
    inter
    fira-code
  ];
}
