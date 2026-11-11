# VSCode 扩展与语言设置。
{
  pkgs,
  userConfig,
  hostConfig,
  lib,
  ...
}:
let
  languageSettings = import ./language-settings.nix {
    inherit
      lib
      pkgs
      userConfig
      hostConfig
      ;
  };
in
{
  programs.vscode = {
    enable = true;
    # 扩展仅声明式安装，避免只读目录冲突（REF:2026-09-12-vscode-extensions-layout-transition）。
    mutableExtensionsDir = false;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions =
        with pkgs.vscode-extensions;
        [
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
        ]
        ++ languageSettings.vscodeExtensions;
      userSettings = {
        "git.confirmSync" = false;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "editor.fontFamily" = "'Maple Mono NF CN', monospace";
        "git.autofetch" = true;
        "git.enableSmartCommit" = true;
        "haskell.plugin.semanticTokens.globalOn" = true;
      }
      // languageSettings.vscodeSettings;
    };
  };
}
