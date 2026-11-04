# Git 工作流、项目环境与密钥工具。
{
  lib,
  pkgs,
  my,
  ...
}:
let
  languageSettings = import ./language-settings.nix { inherit lib pkgs my; };
in
{
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = my.gitUser;
          email = my.gitEmail;
        };
        init.defaultBranch = "main";
      };
    };
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
      extensions = with pkgs; [
        gh-pr-review
        gh-poi
      ];
    };
    gh-dash = {
      enable = true;
    };
    lazygit = {
      enable = true;
      # lg 使用显式缩写，不再注册带目录跳转的同名包装函数。
      enableFishIntegration = false;
    };
    direnv = {
      enable = true;
      enableFishIntegration = false;
      nix-direnv.enable = true;
      silent = false;
    };
    # 容器内可能没有 direnv（REF:2026-08-18-distrobox-container-fish-unknown-command）。
    fish.interactiveShellInit = lib.mkAfter ''
      if type -q direnv
          if not functions -q __direnv_export_eval
              direnv hook fish | source
          end
      end
    '';
    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
    gpg = {
      enable = true;
      settings = {
        default-new-key-algo = "ed25519+cv25519";
        no-symkey-cache = true;
        trust-model = "tofu+pgp";
        with-fingerprint = true;
      };
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
    };
  };
  home.file.".gnupg/gpg-agent.conf".text = ''
    default-cache-ttl 1800
    max-cache-ttl 7200
  '';
  # 跨项目的手动实验工具；项目所需版本仍由各自 devShell 固定。
  home.packages =
    (with pkgs; [
      gcc
      gnumake
      cmake
      ninja
      meson
      pkg-config
      autoconf
      automake
      libtool
      nixfmt
      deadnix
      tinymist
      shellcheck
      tokei
      mold
      sccache
      hyperfine
      jless
      yq
      ouch
      bear
      sops
      age
      pass
      pinentry-curses
    ])
    ++ languageSettings.packages
    ++ [ (if my.nixLanguageServer == "nil" then pkgs.nil else pkgs.nixd) ];
}
