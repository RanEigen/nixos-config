# nixd 必须走 workspace/configuration（REF:2026-09-28-nixd-editor-completion）。
{ pkgs, my, ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" ];
    # 通过 config/user.nix 的 nixLanguageServer 统一选择两个编辑器的服务器。
    userSettings = {
      languages.Nix.language_servers =
        if my.nixLanguageServer == "nil" then
          [
            "nil"
            "!nixd"
          ]
        else
          [
            "nixd"
            "!nil"
          ];
      # 保留 GUI 设置；HM 将此配置合并到可写的 settings.json。
      lsp.nil.settings.nil = {
        formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
        nix.flake = {
          autoArchive = false;
          autoEvalInputs = true;
          nixpkgsInputName = "nixpkgs";
        };
      };
      lsp.nixd.settings = import ./nixd.nix {
        inherit my pkgs;
        system = pkgs.stdenv.hostPlatform.system;
      };
    };
  };
}
