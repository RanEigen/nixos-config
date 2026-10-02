# 左手优先的键位；PrtSc = Print，Page Up/Down = Prior/Next。
_: {
  keybinds = {
    # 帮助与会话
    "Mod+F1" = "cheatsheet-toggle";
    "Mod+Escape" = "spawn:noctalia msg panel-toggle session";
    "Mod+Shift+Z" = {
      action = "shortcuts-inhibit-toggle";
      allow_when_inhibited = true;
      repeat = false;
    };
    # 启动程序
    "Mod+R" = "spawn:noctalia msg panel-toggle launcher";
    "Mod+T" = "spawn:kitty";
    "Mod+B" = "spawn:xdg-open https://www.baidu.com";
    "Mod+E" = "spawn:dolphin";
    # 焦点与窗口移动
    "Mod+Tab" = "spawn:noctalia msg window-switcher";
    "Mod+X" = "spawn:noctalia msg window-switcher";
    "Mod+grave" = "window-focus-next";
    "Mod+Shift+grave" = "window-focus-previous";
    "Mod+W" = "window-focus-up";
    "Mod+A" = "window-focus-left";
    "Mod+S" = "window-focus-down";
    "Mod+D" = "window-focus-right";
    "Mod+Ctrl+W" = "window-move-up";
    "Mod+Ctrl+A" = "column-move-left";
    "Mod+Ctrl+S" = "window-move-down";
    "Mod+Ctrl+D" = "column-move-right";
    # 窗口状态
    "Mod+Q" = "window-close";
    "Mod+F" = "window-toggle-maximize";
    "Mod+Shift+F" = "window-toggle-fullscreen";
    "Mod+V" = "window-toggle-floating";
    "Mod+C" = "window-cycle-primary-extent";
    "Mod+Z" = "overview-toggle";
    # 工作区
    "Mod+WheelDown" = {
      action = "workspace-next";
      cooldown_ms = 150;
    };
    "Mod+WheelUp" = {
      action = "workspace-previous";
      cooldown_ms = 150;
    };
    "Mod+1" = "workspace-switch:1";
    "Mod+2" = "workspace-switch:2";
    "Mod+3" = "workspace-switch:3";
    "Mod+4" = "workspace-switch:4";
    "Mod+5" = "workspace-switch:5";
    "Mod+Ctrl+1" = "column-move-to-workspace:1";
    "Mod+Ctrl+2" = "column-move-to-workspace:2";
    "Mod+Ctrl+3" = "column-move-to-workspace:3";
    "Mod+Ctrl+4" = "column-move-to-workspace:4";
    "Mod+Ctrl+5" = "column-move-to-workspace:5";
    # 截图与剪贴板
    "Mod+Shift+S" = "spawn:noctalia msg screenshot-region";
    "Print" = "spawn:noctalia msg screenshot-region";
    "Mod+Shift+X" = "spawn:noctalia msg panel-toggle clipboard";
    # 声音与亮度：锁屏时仍可使用
    "XF86AudioRaiseVolume" = {
      action = "spawn:noctalia msg volume-up";
      allow_when_locked = true;
    };
    "XF86AudioLowerVolume" = {
      action = "spawn:noctalia msg volume-down";
      allow_when_locked = true;
    };
    "XF86AudioMute" = {
      action = "spawn:noctalia msg volume-mute";
      allow_when_locked = true;
    };
    "XF86MonBrightnessUp" = {
      action = "spawn:noctalia msg brightness-up";
      allow_when_locked = true;
    };
    "XF86MonBrightnessDown" = {
      action = "spawn:noctalia msg brightness-down";
      allow_when_locked = true;
    };
  };
}
