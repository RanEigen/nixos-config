# 本机 Btrfs 快照策略；fileSystems 仍由硬件生成文件管理。
{
  config,
  ...
}:
let
  retention = {
    ALLOW_GROUPS = [ "wheel" ];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = "5";
    TIMELINE_LIMIT_DAILY = "7";
    TIMELINE_LIMIT_WEEKLY = "4";
    TIMELINE_LIMIT_MONTHLY = "3";
    TIMELINE_LIMIT_YEARLY = "1";
    # 重建快照单独按数量清理；至少保留一天，避免高频重建立即挤掉回滚点。
    NUMBER_CLEANUP = true;
    NUMBER_MIN_AGE = "86400";
    NUMBER_LIMIT = "15";
    NUMBER_LIMIT_IMPORTANT = "5";
  };
in
{
  assertions = [
    {
      assertion =
        config.fileSystems."/".fsType == "btrfs" && config.fileSystems."/home".fsType == "btrfs";
      message = "本快照策略要求 / 与 /home 为 Btrfs；请移除 hosts/omen/storage.nix 或配置目标机存储策略。";
    }
  ];
  services = {
    snapper = {
      configs = {
        root = retention // {
          SUBVOLUME = "/";
        };
        home = retention // {
          SUBVOLUME = "/home";
        };
      };
      persistentTimer = true;
    };
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [
        "/"
        "/home"
      ];
    };
  };
  # .snapshots 必须是子卷；此模块不创建目录或修改现有磁盘布局。
}
