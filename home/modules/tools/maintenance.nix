# 通用重建入口；主机可为 nr.body 显式添加快照前置步骤。
{ lib, my, ... }:
{
  programs.fish.functions = {
    nr.body = ''
      nh os switch $argv ${lib.escapeShellArg "${my.repository}#${my.hostname}"}
    '';
    clean-system.body = ''
      nh clean all --keep 15 --keep-since 14d --ask
    '';
  };
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        disable = [
          "system"
          "pi"
          "nix"
          "home_manager"
        ];
        pre_sudo = true;
        set_title = false;
        nix_handler = "nh";
      };
      commands."NixOS 全量更新+重建" =
        "cd ${lib.escapeShellArg my.repository} && nix fmt && nix flake check && fish -c 'nr -u'";
    };
  };
  xdg.configFile."topgrade.toml".force = true;
}
