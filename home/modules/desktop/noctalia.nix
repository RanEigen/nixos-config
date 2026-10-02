# 壳层动态取色；应用配置仍由 HM 管理（REF:2026-09-26-dms-to-noctalia-migration）。
{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    checkConfig = true;
    # GUI 覆盖层优先于此设置；提升配置时先重启会话，再清理对应覆盖键。
    settings = {
      theme = {
        mode = "dark";
        source = "wallpaper";
        templates.builtin_ids = [ ]; # 禁止模板写回 HM 管理的文件。
      };
      shell.panel.transparency_mode = "glass";
      notification.background_opacity = 0.8;
      widget.tray.drawer = true;
      bar.default = {
        background_opacity = 0.75;
        center = [
          "ram"
          "clock"
          "control-center"
          "temp"
        ];
        contact_shadow = true;
        end = [
          "tray"
          "notifications"
          "clipboard"
          "network"
          "bluetooth"
          "volume"
          "battery"
          "session"
        ];
        margin_edge = 5;
        margin_ends = 10;
        radius = 80;
        scale = 1.25;
        start = [
          "launcher"
          "workspaces"
        ];
      };
      widget = {
        clock.format = "{:%H:%M:%S}";
        launcher.custom_image = toString ../../../assets/nixos-logo.png;
      };
      # 壁纸选择留在 GUI 状态中，本地媒体不进入 flake 源。
    };
  };
}
