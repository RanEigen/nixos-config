{
  description = "NixOS 配置";

  inputs = {
    nixpkgs.url = "git+https://mirror.nju.edu.cn/git/nixpkgs.git/?ref=nixos-unstable&shallow=1";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 使用上游构建以复用 Noctalia 二进制缓存。
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    umbriel = {
      url = "github:noctalia-dev/umbriel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omen-rs = {
      url = "github:RanEigen/omen-rs/1ca90bb474dc6b35edc33932c0cb9f3b41cab1be";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      userConfig = import ./config;
      hostConfig = import ./hosts/omen/host.nix { inherit userConfig; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ hostConfig.system ];
      perSystem =
        { system, ... }:
        {
          # Use the same nixpkgs configuration in dev shells and checks.
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config = userConfig.nix.nixpkgsConfig;
          };
        };
      imports = [
        ./flake/devshell.nix
        ./flake/checks.nix
      ];
      flake = {
        overlays.default = final: _prev: {
          # sops-nix 兼容项；退出条件与验证见 docs/maintenance-exceptions.md。
          buildGo125Module = final.buildGoModule;
        };
        nixosConfigurations.${hostConfig.hostName} = inputs.nixpkgs.lib.nixosSystem {
          inherit (hostConfig) system;
          specialArgs = {
            inherit inputs;
            inherit userConfig;
            inherit hostConfig;
          };
          modules = [
            inputs.chaotic.nixosModules.default
            ./hosts/omen
          ];
        };
      };
    };
}
