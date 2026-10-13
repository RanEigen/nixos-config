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
  comfyuiBase = pkgsComfyui.comfyui.override {
    withManager = true;
  };
  comfyuiSource = pkgs.fetchFromGitHub {
    owner = "Comfy-Org";
    repo = "ComfyUI";
    # 2026-10-03 main: includes the local FLUX.2 Klein and Qwen Image 2.1 nodes.
    rev = "e9027f2b30f37bb3052714eb08fcf479542f4fc0";
    hash = "sha256-iXRJsZVjZ70VfNCGcUhp+PlYUF8IXItmqlPpDReF5Uk=";
  };
  comfyuiLauncher = pkgs.writeShellScriptBin "comfyui" ''
    data_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/comfyui"
    export PYTHONPATH="$data_dir/python-packages''${PYTHONPATH:+:$PYTHONPATH}"
    export LD_LIBRARY_PATH="${
      pkgs.lib.makeLibraryPath [
        pkgs.zlib
        pkgs.stdenv.cc.cc.lib
      ]
    }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export AUX_ANNOTATOR_CKPTS_PATH="$data_dir/models/auxiliary"
    export AUX_TEMP_DIR="$data_dir/cache/controlnet-aux"
    exec ${comfyuiBase.pythonEnv}/bin/python ${comfyuiSource}/main.py \
      --base-directory "$data_dir" "$@"
  '';
in
{
  home.packages = [ comfyuiLauncher ];
  home.file.".local/bin/comfyui".source = "${comfyuiLauncher}/bin/comfyui";
}
