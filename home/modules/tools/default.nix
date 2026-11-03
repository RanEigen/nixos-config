{
  imports = [
    ./fish.nix # Shell、插件与快捷命令
    ./starship.nix # 提示符
    ./yazi.nix # 文件管理器
    ./shell-utils.nix # 通用 CLI 与 shell 集成
    ./monitoring.nix # 终端监控工具
    ./fastfetch.nix # 终端系统信息
    ./maintenance.nix # 非 Nix 软件升级
  ];
}
