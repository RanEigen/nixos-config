# 本机 CPU 调度、功耗与资源限额；移除 import 即关闭本组策略。
{ config, pkgs, ... }:
{
  assertions = [
    {
      assertion = config.networking.hostName == "omen";
      message = "此功耗策略仅适用于已核验的 OMEN；请移除 hosts/omen/performance.nix 并配置目标机。";
    }
  ];
  environment.systemPackages = [
    config.boot.kernelPackages.cpupower
    pkgs.tlp-pd
  ];
  services = {
    system76-scheduler.enable = true;
    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
    irqbalance.enable = true;
    tlp = {
      enable = true;
      settings = {
        # 动态调频避免线圈啸叫（REF:2026-08-25-coil-whine-cpu-governor）。
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      };
    };
    power-profiles-daemon.enable = false;
  };
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
}
