# 本机 NVIDIA 混合显卡、蓝牙与视频加速。
{ pkgs, config, ... }:

{
  assertions = [
    {
      assertion = config.networking.hostName == "omen";
      message = "此模块包含 OMEN 固定 PCI 地址；请移除 hosts/omen/hardware.nix 并使用目标机硬件配置。";
    }
  ];
  hardware = {
    # NVIDIA RTX 4060
    nvidia = {
      open = false;
      modesetting.enable = true;
      nvidiaPersistenced = true;
      # 电源管理（nvidia 官方推荐；配合 nvidia-drm.modeset=1）
      powerManagement.enable = true;
      # 40 系移动端显存精细电源管理
      powerManagement.finegrained = true;
      # 驱动随所选内核配套，覆盖备用内核场景。
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      # 13 代核显视频硬解：iHD 必需；libva-vdpau-driver + libvdpau-va-gl 兼容老 X11 应用
      extraPackages = with pkgs; [
        intel-media-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
    bluetooth.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    # 不全局强制 NVIDIA；需要独显的程序使用 nvidia-offload 启动。
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
