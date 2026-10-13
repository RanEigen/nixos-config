# 护眼由会话服务管理；手动开关使用 systemctl --user start/stop wlsunset。
{
  services.wlsunset = {
    enable = true;
    # 延续原配置位置；按经纬度计算日出日落，不同时设置 duration。
    latitude = 36.5;
    longitude = 128.0;
    temperature = {
      day = 6500;
      night = 5000;
    };
  };
}
