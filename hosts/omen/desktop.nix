# HDMI-A-1 / 1080p 锁屏布局与合成器输出。
{ pkgs, ... }:
let
  widget = type: cx: cy: width: height: {
    inherit type cx cy;
    box_width = width;
    box_height = height;
    output = "HDMI-A-1";
    placement_width = 1920.0;
    placement_height = 1080.0;
    rotation = 0.0;
  };
in
{
  programs.noctalia.settings.lockscreen_widgets = {
    enabled = true;
    schema_version = 2;
    widget_order = [
      "lockscreen-login-box@HDMI-A-1"
      "lockscreen-widget-0000000000000001"
      "lockscreen-widget-0000000000000003"
      "lockscreen-widget-0000000000000004"
      "lockscreen-widget-0000000000000005"
    ];
    grid = {
      cell_size = 16;
      major_interval = 4;
      visible = true;
    };
    widget = {
      "lockscreen-login-box@HDMI-A-1" = widget "login_box" 960.0 898.0 810.0 196.0 // {
        settings = {
          background_color = "surface_variant";
          background_opacity = 0.88;
          background_radius = 12.0;
          center_password_text = false;
          input_opacity = 1.0;
          input_radius = 6.0;
          layout = "regular";
          show_caps_lock = true;
          show_keyboard_layout = true;
          show_login_button = true;
          show_media = true;
          show_session_buttons = true;
          show_unlock_hint = true;
          show_weather = true;
        };
      };
      "lockscreen-widget-0000000000000001" = widget "fancy_audio_visualizer" 688.0 412.0 368.0 352.0 // {
        settings.background = false;
      };
      "lockscreen-widget-0000000000000003" = widget "clock" 944.0 412.0 416.0 224.0 // {
        settings = {
          background_opacity = 0.0;
          clock_style = "digital";
        };
      };
      "lockscreen-widget-0000000000000004" = widget "sysmon" 752.0 636.0 352.0 160.0 // {
        settings = {
          background_color = "outline";
          background_opacity = 0.0;
          display = "graph";
          stat = "ram_pct";
          stat2 = "cpu_usage";
        };
      };
      "lockscreen-widget-0000000000000005" = widget "sysmon" 1184.0 652.0 352.0 160.0 // {
        settings = {
          background_color = "outline";
          background_opacity = 0.0;
          color = "on_primary";
          color2 = "on_secondary";
          display = "graph";
          stat = "net_tx";
          stat2 = "net_rx";
        };
      };
    };
  };
  xdg.configFile."umbriel/machine.toml".source =
    (pkgs.formats.toml { }).generate "umbriel-machine.toml"
      {
        environment.GSK_RENDERER = "gl";
        output."eDP-1".enabled = false;
        output."HDMI-A-1" = {
          mode = "1920x1080@144";
          position = [
            0
            0
          ];
          scale = 1.0;
        };
      };
}
