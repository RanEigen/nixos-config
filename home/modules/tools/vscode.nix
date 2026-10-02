# VSCode 扩展与 nixd 配置。
{ pkgs, my, ... }:
{
  programs.vscode = {
    enable = true;
    # 扩展仅声明式安装，避免只读目录冲突（REF:2026-09-12-vscode-extensions-layout-transition）。
    mutableExtensionsDir = false;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        christian-kohler.path-intellisense
        mkhl.direnv
        ms-ceintl.vscode-language-pack-zh-hans
        timonwong.shellcheck
        redhat.vscode-yaml
        tamasfe.even-better-toml
        usernamehw.errorlens
        eamodio.gitlens
        myriad-dreamin.tinymist
        haskell.haskell
        rust-lang.rust-analyzer
      ];
      userSettings = {
        "git.confirmSync" = false;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "editor.fontFamily" = "'Maple Mono NF CN', monospace";
        "git.autofetch" = true;
        "git.enableSmartCommit" = true;
        "haskell.manageHLS" = "PATH";
        "haskell.plugin.semanticTokens.globalOn" = true;
        "haskell.formattingProvider" = "fourmolu";
        "[nix]"."editor.formatOnSave" = true;
        "nix.enableLanguageServer" = true;
        # 与 Zed 共用 config/user.nix 中的服务器选择。
        "nix.serverPath" =
          if my.nixLanguageServer == "nil" then
            "nil"
          else
            [
              "nixd"
              "--semantic-tokens"
            ];
        "editor.semanticHighlighting.enabled" = true;
        # 不使用 initialization_options（REF:2026-09-28-nixd-editor-completion）。
        "nix.serverSettings".nil = {
          formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
          nix.flake = {
            autoArchive = false;
            autoEvalInputs = true;
            nixpkgsInputName = "nixpkgs";
          };
        };
        "nix.serverSettings".nixd =
          (import ./nixd.nix {
            inherit my pkgs;
            system = pkgs.stdenv.hostPlatform.system;
          })
          // {
            eval.target = {
              args = [ "--impure" ];
              installable = ".#nixosConfigurations.${my.hostname}.config.system.build.toplevel";
            };
          };
      };
    };
  };
}
