# 用户目录与默认应用。
{
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      desktop = "Desktop";
      documents = "Documents";
      download = "Downloads";
      music = "Music";
      pictures = "Pictures";
      publicShare = "Public";
      templates = "Templates";
      videos = "Videos";
    };
    mimeApps = {
      enable = true;
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
    };
  };
}
