# 登录环境的语言、时区与授时。
{
  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "C.UTF-8/UTF-8"
    ];
  };
  time.timeZone = "Asia/Shanghai";
  time.hardwareClockInLocalTime = false;
  services.timesyncd.servers = [
    "ntp.ntsc.ac.cn"
    "cn.ntp.org.cn"
    "ntp.sjtu.edu.cn"
  ];
}
