# 本机 NUT75 网页驱动权限与 Fn+P 启动宏兼容。
{
  pkgs,
  lib,
  my,
  ...
}:
let
  driverUrl = "https://weikav.driveall.cn/";
in
{
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "nut75-udev-rules";
      destination = "/lib/udev/rules.d/70-nut75.rules";
      # uaccess 必须早于 73-seat-late.rules；仅开放厂商接口，不开放键盘输入。
      # REF:2026-10-07-nut75-webhid
      text = ''
        ACTION!="remove", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0c45", ATTRS{idProduct}=="880c", ENV{ID_USB_INTERFACE_NUM}=="03|04", TAG+="uaccess"
      '';
    })
  ];

  # Fn+P 的 Win+R → 网址 → 回车通过启动器匹配此名称；只执行固定命令。
  home-manager.users.${my.username}.xdg.desktopEntries.nut75-driver = {
    name = driverUrl;
    genericName = "NUT75 网页驱动";
    exec = "${lib.getExe pkgs.google-chrome} ${driverUrl}";
    icon = "input-keyboard";
    terminal = false;
    categories = [
      "Settings"
      "HardwareSettings"
    ];
    settings.Keywords = "NUT75;weikav;";
  };
}
