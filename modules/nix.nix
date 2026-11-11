# Nix 客户端、缓存与 Store 维护。
{
  inputs,
  userConfig,
  hostConfig,
  pkgs,
  ...
}:
let
  goProxy = "https://goproxy.cn,direct";
in
{
  imports = [ inputs.nix-index-database.nixosModules.nix-index ];
  nixpkgs.overlays = [ inputs.self.overlays.default ];
  # 保留完整的 Nix 管理、打包、排障与部署工具，不要求先进入 devShell。
  environment.systemPackages = with pkgs; [
    nix-update
    nix-du
    nix-tree
    dix
    nixdoc
    nix-init
    nix-prefetch
    nix-eval-jobs
    hydra-check
    npc
    nix-output-monitor
    flake-checker
    nix-melt
    nix-health
    nvd
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
        # 显式优先于官方缓存（默认 40）；列表顺序不代表缓存优先级。
        "https://mirror.sjtu.edu.cn/nix-channels/store?priority=20"
        "https://mirror.nju.edu.cn/nix-channels/store?priority=30"
        # Keep the project-specific cache used by the Noctalia Flake input.
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
      trusted-users = [
        "@wheel"
        userConfig.user.userName
      ];
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
        "auto-allocate-uids"
        "cgroups"
      ];
      # Store 去重交给定时 optimise，避免每次导入都扫描；GC 使用默认输出保留策略。
      min-free = "2G";
      max-free = "8G";
      http2 = false;
      connect-timeout = 3;
      stalled-download-timeout = 90;
      filetransfer-retry-attempts = 2;
      # High network concurrency for cache lookups and downloads. This can
      # improve throughput, but increases pressure on caches and the daemon.
      http-connections = 64;
      max-substitution-jobs = 32;
      warn-dirty = false;
      max-jobs = "auto";
      cores = 0;
      builders-use-substitutes = true;
      log-lines = 50;
    };
    extraOptions = ''
      include ${hostConfig.nixAccessTokensFile}
    '';
    # sops include 仅在激活后存在；缺失时由 secrets.nix 预置空文件。
    checkAllErrors = false;
    # 自动清理使用 nh 的代际/时间保留策略；手动清理须显式选择保留参数。
    gc.automatic = false;
    optimise.automatic = true;
  };

  systemd.services.nix-daemon.environment.GOPROXY = goProxy;
  environment.sessionVariables.GOPROXY = goProxy;
  programs = {
    nh = {
      enable = true;
      flake = hostConfig.configurationRepository;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 15 --keep-since 14d";
      };
    };
    nix-index.enable = true;
    nix-index-database.comma.enable = true;
    command-not-found.enable = false;
  };
}
