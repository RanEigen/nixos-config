# 护眼由会话服务管理；手动开关使用 systemctl --user start/stop wlsunset。
{ my, ... }:
{
  services.wlsunset = {
    enable = true;
    # 地理位置为用户偏好；按经纬度计算日出日落，不同时设置 duration。
    inherit (my.sunLocation) latitude longitude;
    temperature = {
      day = 6500;
      night = 5000;
    };
  };
}
