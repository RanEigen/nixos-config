# 登录环境的语言、时区与授时；个人 locale 来自 config/user.nix。
{ userConfig, ... }:
{
  i18n = {
    defaultLocale = userConfig.preferences.locale.defaultLocale;
    supportedLocales = userConfig.preferences.locale.supportedLocales;
  };
  time.timeZone = userConfig.preferences.locale.timeZone;
  time.hardwareClockInLocalTime = false;
  services.timesyncd.servers = [
    "ntp.ntsc.ac.cn"
    "cn.ntp.org.cn"
    "ntp.sjtu.edu.cn"
  ];
}
