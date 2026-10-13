# Nix 客户端、缓存与 Store 维护。
{
  inputs,
  my,
  pkgs,
  ...
}:
let
  goProxy = "https://goproxy.cn,direct";
in
{
  imports = [ inputs.nix-index-database.nixosModules.nix-index ];
  nixpkgs.overlays = [ inputs.self.overlays.default ];
  # Nix 管理与排障 CLI；用户级工具仍由 Home Manager 或 devShell 管理。
  environment.systemPackages = with pkgs; [
    nix-update
    nix-du
    nix-tree
    nixdoc
    nix-init
    nix-output-monitor
    flake-checker
    nix-melt
    nix-health
    nixd
    nil
    nixfmt
    nvd
    deadnix
    devenv
    cachix
    angrr
    optnix
    manix
    nix-search-tv
    nixos-anywhere
    fh
  ];

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      # cache.nixos.org 及其公钥由 nixpkgs 默认提供。
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirror.nju.edu.cn/nix-channels/store"
        "https://devenv.cachix.org"
        "https://numtide.cachix.org"
        "https://nix-community.cachix.org"
        "https://mic92.cachix.org"
        "https://git-hooks.cachix.org"
        "https://pre-commit-hooks.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://noctalia.cachix.org"
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
        "git-hooks.cachix.org-1:t3VIYDdXlezkNY1/sRtYKzxMVKTgn+uAR9VWCXHRPeI="
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
      trusted-users = [
        "@wheel"
        my.username
      ];
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
        "auto-allocate-uids"
        "cgroups"
      ];
      auto-optimise-store = true;
      keep-outputs = true;
      min-free = "2G";
      max-free = "8G";
      http2 = false;
      connect-timeout = 5;
      stalled-download-timeout = 90;
      http-connections = 24;
      max-substitution-jobs = 24;
      warn-dirty = false;
      max-jobs = "auto";
      cores = 0;
      builders-use-substitutes = true;
      log-lines = 50;
    };
    extraOptions = ''
      include ${my.nixAccessTokensPath}
    '';
    # sops include 仅在激活后存在；缺失时由 secrets.nix 预置空文件。
    checkAllErrors = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
  };

  systemd.services.nix-daemon.environment.GOPROXY = goProxy;
  environment.sessionVariables.GOPROXY = goProxy;
  programs = {
    nh = {
      enable = true;
      flake = my.repository;
    };
    nix-index.enable = true;
    nix-index-database.comma.enable = true;
    command-not-found.enable = false;
  };
}
