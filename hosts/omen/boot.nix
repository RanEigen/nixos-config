# 本机 EFI/Limine、默认 Zen 内核及双系统入口。
{
  config,
  pkgs,
  lib,
  ...
}:
{
  assertions = [
    {
      assertion = config.networking.hostName == "omen";
      message = "本引导配置包含 OMEN 显示器和 NVIDIA 参数；请移除 hosts/omen/boot.nix 并配置目标机。";
    }
  ];
  catppuccin.limine.enable = true;
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
    tmp = {
      useZram = true;
      cleanOnBoot = true;
      zramSettings = {
        zram-size = "ram * 1.0";
        compression-algorithm = "zstd";
        fs-type = "ext4";
      };
    };
    loader = {
      timeout = null;
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        maxGenerations = 3; # ESP 容量限制；保留回滚入口。
        enableEditor = true;
        resolution = "1920x1200x32";
        # 颜色由 catppuccin.limine 提供，避免覆盖其主题。
        style = {
          interface = {
            resolution = "auto";
            branding = "◆ Omen 16";
            helpHidden = true;
          };
          graphicalTerminal = {
            font = {
              scale = "2x2";
              spacing = 2;
            };
            margin = 180;
            marginGradient = 75;
          };
        };
        extraEntries = ''
          /Windows 11
            protocol: efi_boot_entry
            entry: Windows Boot Manager
        '';
      };
    };
    kernelParams = [
      "ibt=off"
      "nvidia-drm.modeset=1"
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "vt.global_cursor_default=0"
    ];
  };
}
