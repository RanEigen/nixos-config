{
  locale = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "C.UTF-8/UTF-8"
    ];
    language = "zh_CN:en";
    ctypeLocale = "en_US.UTF-8";
    timeZone = "Asia/Shanghai";
  };
  # 用户全局所在地（日出日落计算），与主机硬件无关。
  sunLocation = {
    latitude = 36.5;
    longitude = 128.0;
  };
  fonts = {
    terminal = "Maple Mono NF CN";
    interface = "LXGW Neo XiHei";
    screenshot = "LXGW Neo XiHei";
  };
  desktop = {
    iconTheme = "Papirus-Dark";
    cursorSize = 30;
    defaultApplications = {
      "text/html" = "chrome.desktop";
      "application/xhtml+xml" = "chrome.desktop";
      "x-scheme-handler/http" = "chrome.desktop";
      "x-scheme-handler/https" = "chrome.desktop";
      "x-scheme-handler/about" = "chrome.desktop";
      "x-scheme-handler/unknown" = "chrome.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "video/webm" = "mpv.desktop";
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/avi" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "application/x-shellscript" = "nvim.desktop";
      "text/plain" = "nvim.desktop";
      "inode/directory" = "org.kde.dolphin.desktop";
    };
    userDirectories = {
      desktop = "Desktop";
      documents = "Documents";
      download = "Downloads";
      music = "Music";
      pictures = "Pictures";
      publicShare = "Public";
      templates = "Templates";
      videos = "Videos";
    };
  };
  catppuccin = rec {
    flavor = "mocha";
    accent = "mauve";
    palette = {
      text = "#cdd6f4";
      crust = "#11111b";
      subtext0 = "#a6adc8";
      mauve = "#cba6f7";
      red = "#f38ba8";
      teal = "#94e2d5";
      sapphire = "#74c7ec";
      blue = "#89b4fa";
      green = "#a6e3a1";
      pink = "#f5c2e7";
      peach = "#fab387";
      yellow = "#f9e2af";
      overlay1 = "#8087a2";
      surface0 = "#313244";
      surface2 = "#585b70";
      shadow = "#000000B3";
    };
    names = {
      fcitx5 = "catppuccin-${flavor}-${accent}";
      gtk = "catppuccin-${flavor}-${accent}-standard";
    };
  };
  # Nix 编辑器语言服务器是开发偏好，不是 Nix daemon 策略。
  nixLanguageServer = "nixd";
}
