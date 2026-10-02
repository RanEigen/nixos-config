# 窗口与图层规则：后规则覆盖同窗口的前规则属性。
# 当前无窗口级防录屏能力，共享屏幕时须自行隐藏敏感窗口。
_:

{
  # ---- 图层规则：Noctalia 壳层毛玻璃 ----
  # namespace 源码实锤：noctalia-bar-<profile>/panel/attached-panel/notification/osd/dock
  layer_rule = [
    {
      match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|desktop-widget-.+)$";
      blur = true;
      blur_ignore_alpha = 0.5;
      blur_popups = true;
      blur_optimized = false; # 模糊真实窗口内容
    }
  ];

  window_rule = [
    # ---- 全局毛玻璃：所有窗口半透明 + 圆角 + 背景模糊 ----
    # blur_optimized 不写 = 默认 true：仅模糊一次壁纸背景供所有窗口复用，零额外消耗
    {
      opacity = 0.94;
      corner_radius = 12;
      blur = true;
    }

    # ---- kitty 毛玻璃终端 ----
    # kitty 自行控制透明度，避免合成器再次乘算。
    {
      match.app_id = "^kitty$";
      opacity = 1.0;
      corner_radius = 12;
      blur = true;
      blur_optimized = false;
    }

    # ---- 浮动窗口：更透 + 实时模糊 ----
    {
      match.is_floating = true;
      opacity = 0.9;
      blur = true;
      blur_optimized = false;
    }

    # ---- imv 图片预览：浮动打开且不自动聚焦 ----
    {
      match.app_id = "imv";
      default_focused = false;
      default_floating = true;
    }

    # ---- 常见浮动软件清单（正则 alternation 合并同组 app-id）----
    {
      match.app_id = "^(com\\.gabm\\.satty|media_info|video2gif|floating-term|nm-connection-editor|blueman-manager|flameshot|be\\.alexandervanhee\\.gradia|org\\.gnome\\.FileRoller|markpix|better_control\\.py|floating-mpv)$";
      default_floating = true;
    }

    # ---- app-id + 标题联合匹配 ----
    {
      match.app_id = "firefox$";
      match.title = "^Picture-in-Picture$";
      default_floating = true;
    }
    {
      match.app_id = "steam";
      match.title = "Friends List";
      default_floating = true;
    }
    {
      match.app_id = "blueberry.py";
      match.title = "蓝牙";
      default_floating = true;
    }
    {
      match.app_id = "org.pulseaudio.pavucontrol";
      match.title = "音量控制";
      default_floating = true;
    }
    {
      match.app_id = "org.gnome.clocks";
      match.title = "时钟";
      default_floating = true;
    }
    {
      match.app_id = "fcitx";
      match.title = "Fcitx5 Input Window";
      default_floating = true;
    }

    # ---- 通用标题弹窗 ----
    {
      match.title = "^(群聊的聊天记录|聊天记录|群相册|日历|重命名|另存为|Steam 设置)$";
      default_floating = true;
    }

    # ---- QQ 资料卡/天气：不自动聚焦 ----
    {
      match.app_id = "QQ";
      match.title = "^(资料卡|天气)$";
      default_focused = false;
    }

    # ---- 快速终端和笔记：浮动 + 左上角定位 ----
    {
      match.app_id = "^(notebook|quickterminal)$";
      default_floating = true;
      default_position = {
        x = 20;
        y = 20;
        anchor = "top_left";
      };
    }

    # ---- bluetui / impala：固定 800x800 浮动 ----
    {
      match.app_id = "^(bluetui|impala)$";
      default_floating = true;
      default_floating_size_px = {
        width = 800;
        height = 800;
      };
    }

    # ---- waydroid / gsr ui：全屏浮动、无边框无阴影、不透明 ----
    {
      match.app_id = "waydroid";
      default_fullscreen = true;
      default_floating = true;
      border_width = 0;
      shadow = false;
      opacity = 1.0;
    }
    {
      match.title = "gsr ui";
      default_fullscreen = true;
      default_floating = true;
      border_width = 0;
      shadow = false;
    }

    # ---- 图片/视频查看类窗口：不透明 + 浮动 ----
    {
      match.title = "^(图片查看器|画中画|图片和视频|视频播放器)$";
      default_floating = true;
      opacity = 1.0;
    }

    # ---- mpv / celluloid：不透明（播放器保持实色）----
    {
      match.app_id = "^(mpv|celluloid)$";
      opacity = 1.0;
    }

    # ---- steam 好友弹出通知：右下角 + 不聚焦 + 置顶 ----
    {
      match.app_id = "steam";
      match.title = "^notificationtoasts_\\d+_desktop$";
      default_position = {
        x = 10;
        y = 10;
        anchor = "bottom_right";
      };
      default_focused = false;
      default_pinned = true;
    }

  ];
}
