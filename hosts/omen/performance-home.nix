# OMEN / Intel RAPL 性能命令（REF:2026-08-23-omen-ec）。
{
  programs.fish.functions = {
    perf-status = ''
      set -l gov (cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
      set -l epp (cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null)
      set -l pl1 (cat /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null)
      set -l pl2 (cat /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw 2>/dev/null)
      echo "── EC 性能状态 ──"
      omen remote perf
      echo "governor: $gov"
      echo "EPP: $epp"
      echo "RAPL PL1/PL2: "(math $pl1 / 1000000)"W / "(math $pl2 / 1000000)"W"
    '';
    perf-boost = ''
      echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference >/dev/null
    '';
    perf-economy = ''
      echo balance_performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference >/dev/null
    '';
    perf-test = ''
      echo "32 核满载 6 秒采样..."
      set -l workers
      for i in (seq 32)
          yes >/dev/null &
          set -a workers $last_pid
      end
      sleep 6
      awk -F: '/MHz/{s+=$2; n++} END{printf "满载平均: %.0f MHz (上限 5200)\n", s/n}' /proc/cpuinfo
      kill $workers 2>/dev/null
    '';
    perf-unlock = ''
      sudo omen unlock; or return 1
      omen remote perf
      perf-test
    '';
  };
}
