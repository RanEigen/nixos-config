# 非 Nix 软件升级；系统重建与清理使用完整命令。
{
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        disable = [
          "system"
          "pi"
          "nix"
          "nix_helper"
          "home_manager"
          # These applications are upgraded with the Nix configuration.
          "opencode"
          "codex"
          "zed"
          "vscode"
          "yazi"
          "self_update"
        ];
        pre_sudo = true;
        set_title = false;
      };
    };
  };
}
