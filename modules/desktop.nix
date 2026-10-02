# 登录、桌面会话、认证与 portal。
{ pkgs, ... }:
{
  # LocalSend 随桌面部署；基础配置不开放此端口。
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
  programs = {
    umbriel.enable = true;
    noctalia.enable = true;
    dconf.enable = true;
  };
  services.displayManager.noctalia-greeter.enable = true;
  security.polkit.enablePkexecWrapper = true;
  # 上游 helper 以固定 action 同步外观；无 logind 会话，不能要求 subject.active/local。
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.noctalia.greeter.sync-appearance"
          && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
  users.groups.greeter = { };
  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
  };
  services.greetd = {
    enable = true;
    # command 由 greeter 模块提供，不能用显式值覆盖。
    settings.default_session.user = "greeter";
  };
  systemd.services.greetd.unitConfig = {
    StartLimitIntervalSec = "300";
    StartLimitBurst = 30;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };
  environment.systemPackages = [ pkgs.gsettings-desktop-schemas ];
  environment.sessionVariables.GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${pkgs.gsettings-desktop-schemas.version}/glib-2.0/schemas";
}
