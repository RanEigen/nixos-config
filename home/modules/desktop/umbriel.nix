# 合成器核心；键位与规则为同层纯数据文件。
{
  config,
  my,
  ...
}:

let
  palette = my.catppuccin.palette;
  binds = import ./umbriel-binds.nix { };
  rules = import ./umbriel-rules.nix { };

  core = {
    # 主机可提供输出配置；缺失时使用自动布局。
    include.optional.files = [ "machine.toml" ];

    general = {
      # environment 由合成器同步至 systemd user manager。
      autostart = [
        "noctalia" # 桌面壳（bar/启动器/壁纸/锁屏/通知/窗口切换器）
        "fcitx5" # 输入法
        "xhost +si:localuser:root" # 允许 root 经用户 xwayland-satellite 开窗
        "${config.home.homeDirectory}/.config/umbriel/scripts/toggle-wlsunset" # 护眼
      ];
      show_cheatsheet = true;
    };

    # 合成器作用域环境；系统会话作用域见 modules/input-method.nix。
    # STANDARDS §4：IM 变量双作用域（REF:2026-08-21-fcitx5-gtk）
    environment = {
      LANGUAGE = "zh_CN:en";
      LANG = "zh_CN.UTF-8";
      LC_CTYPE = "en_US.UTF-8"; # 漏字修复（副作用：steam 等 X11 应用可能无法用中文输入法）
      XMODIFIERS = "@im=fcitx";
      QT_IM_MODULES = "wayland;fcitx"; # Qt6 原生 text-input-v3 优先，fcitx 兜底
      QT_IM_MODULE = "fcitx";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
      QS_ICON_THEME = "Papirus-Dark"; # Noctalia 外壳图标主题
      EDITOR = "vim";
    };

    input = {
      keyboard = {
        # 不写 layout/variant = 从系统 XKB 取（localectl 管理）
        repeat_rate = 35;
        repeat_delay = 250;
      };
      touchpad = {
        tap = true;
        natural_scroll = true;
      };
      mouse = {
        sensitivity = -0.15; # 轻微降速
        accel_profile = "flat"; # 禁用鼠标加速
      };
      cursor = {
        # 单一来源 = home.pointerCursor（home/modules/theme/appearance.nix）
        theme = config.home.pointerCursor.name;
        size = config.home.pointerCursor.size;
        hide_timeout_ms = 15000; # 闲置 15s 自动隐藏
      };
    };

    layout = {
      gap = 12;
      extent_presets = [
        0.33333
        0.5
        0.66667
      ];
      scrolling.default_extent_fraction = 0.5;
      scrolling.center_focused = "never";
    };

    appearance = {
      prefer_no_csd = true;
      border_width = 3; # 焦点边框宽度
      corner_radius = 12;
      blur = {
        enabled = true;
        passes = 2; # 省 GPU（默认 3）
        radius = 5;
        noise = 0.02;
        saturation = 1.4;
      };
      shadow = {
        enabled = true;
        softness = 20;
        offset_x = -4;
        offset_y = -4;
      };
    };

    # 固定主题色；桌面壳另行使用壁纸取色。
    colors = {
      background = palette.surface2; # umbriel 面板兜底色
      backdrop = palette.surface2;
      inherit (palette) shadow;
      border = {
        focused = palette.mauve;
        unfocused = palette.surface2;
        outer = palette.overlay1;
      };
    };

    overview = {
      zoom = 0.5;
    };

    # 动画：spring:<damping>,<stiffness>
    animation = {
      workspaces.curve = "spring:0.82,400";
      windows_in = {
        curve = "spring:1.0,1000";
        style = "popin";
      };
      windows_out = {
        curve = "spring:0.8,400";
        style = "popin";
      };
      windows_move.curve = "spring:1.0,800";
      overview.curve = "spring:1.0,900";
    };
  };
in
{
  programs.umbriel = {
    enable = true;
    # NixOS 模块安装会话包，HM 只生成配置。
    package = null;
    settings = core // binds // rules;
  };

  # 启动脚本目录（护眼 toggle-wlsunset；与合成器无关）
  xdg.configFile."umbriel/scripts" = {
    source = ../../../assets/scripts;
    recursive = true;
    force = true;
  };
}
