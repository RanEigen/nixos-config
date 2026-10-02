{
  imports = [
    ./system.nix # 系统历史版本与包策略
    ./network.nix # 主机标识、网络管理与 TCP 策略
    ./users.nix # 用户、权限与登录 shell
    ./locale.nix # 语言、时区与授时
    ./nix.nix # Nix 缓存、GC 与客户端工具
    ./nix-compat.nix # 非 Nix 二进制运行库
    ./packages.nix # 系统排障工具
    ./secrets.nix # 秘密声明与运行时注入
    ./home-manager.nix # 用户环境集成
  ];
}
