{
  imports = [
    ./configuration.nix # 本机组合与用户接线
    ./hardware-configuration.nix # 生成的磁盘与硬件事实
    ./hardware.nix # GPU、蓝牙与显卡环境
    ./nut75.nix # NUT75 网页驱动设备权限
    ./boot.nix # 引导、内核与 Windows 启动项
    ./multikernel.nix # 备用内核
    ./storage.nix # 快照与 scrub
    ./performance.nix # 调度、功耗与资源限额
    ./omen.nix # EC 解锁与风扇策略
    ./proxy # 透明代理与可移除客户端集成
  ];
}
