# 托盘入口随桌面用户配置迁移；应用本体由 NixOS 系统包提供。
_: {
  programs.noctalia.settings.widget.tray.pinned = [
    "tray-icon tray app clash-verge-rev-tray"
  ];
}
