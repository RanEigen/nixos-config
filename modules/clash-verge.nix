# 桌面代理客户端由 nixpkgs 的 NixOS 模块安装和管理。
_: {
  programs.clash-verge = {
    enable = true;
    serviceMode = true;
    tunMode = true;
  };
}
