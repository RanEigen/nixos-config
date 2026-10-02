# 使用固定的 CUDA 版本以命中二进制缓存；升级输入前确认缓存可用。
# CUDA 支持仅对 ComfyUI 包集启用。
{
  pkgs,
  inputs,
  ...
}:
let
  pkgsComfyui = import inputs.nixpkgs-comfyui {
    inherit (pkgs.stdenv.hostPlatform) system;
    config = pkgs.config // {
      cudaSupport = true;
    };
  };
in
{
  home.packages = [
    (pkgsComfyui.comfyui.override {
      # 图形界面内可安装自定义节点；需要额外 pip 依赖的节点在 Nix 环境里会失败。
      withManager = true;
    })
  ];
}
