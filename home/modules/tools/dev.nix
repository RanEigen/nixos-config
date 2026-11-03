# Git 工作流、项目环境与密钥工具。
{
  lib,
  pkgs,
  my,
  ...
}:
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
  };
  home.file.".gnupg/gpg-agent.conf".text = ''
    default-cache-ttl 1800
    max-cache-ttl 7200
  '';
  home.packages = with pkgs; [
    # 跨项目的手动实验工具；项目所需版本仍由各自 devShell 固定。
    gcc
    gnumake
    cmake
    ninja
    meson
    pkg-config
    autoconf
    automake
    libtool
    nixd
    nil
    nixfmt
    deadnix
    tinymist
    shellcheck
    tokei
    mold
    sccache
    sops
    age
    pass
    pinentry-curses
  ];
}
