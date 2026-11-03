# 登录环境的语言、时区与授时；个人 locale 来自 config/user.nix。
{ my, ... }:
{
  i18n = {
    defaultLocale = my.locale.default;
    supportedLocales = my.locale.supported;
  };
  time.timeZone = my.locale.timeZone;
  time.hardwareClockInLocalTime = false;
  services.timesyncd.servers = [
    "ntp.ntsc.ac.cn"
    "cn.ntp.org.cn"
    "ntp.sjtu.edu.cn"
  ];
}
