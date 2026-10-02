# 无专属配置的桌面应用与会话工具。
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # 浏览器与应用
    firefox
    google-chrome
    imv
    opencode
    pi-coding-agent
    codex
    wpsoffice-cn
    obsidian
    wechat
    # KDE 文件与文档工具
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.ark
    kdePackages.ffmpegthumbs
    kdePackages.kimageformats
    kdePackages.okular
    # 会话工具
    wl-clipboard
    wlsunset
    libnotify
    udiskie
    localsend
  ];
}
