{
  imports = [
    ./dae.nix # 透明接管与后端网络
    ./clash.nix # 开源代理客户端
    ./fcclient.nix # 可选私有客户端集成；移除本行即可解除接线
  ];
}
