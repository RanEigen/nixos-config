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
      url = "github:jackockzuo/omen-rs/1ca90bb474dc6b35edc33932c0cb9f3b41cab1be";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      my = import ./config/user.nix;
      hosts = {
        omen = {
          system = "x86_64-linux";
          hostId = "007f0200";
          systemStateVersion = "25.05";
        };
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        (import ./flake/devshell.nix { inherit inputs my; })
        ./flake/checks.nix
      ];
      flake = {
        overlays.default = final: _prev: {
          # sops-nix 兼容项；退出条件与验证见 docs/maintenance-exceptions.md。
          buildGo125Module = final.buildGoModule;
        };
        nixosConfigurations = inputs.nixpkgs.lib.mapAttrs (
          hostname: host:
          inputs.nixpkgs.lib.nixosSystem {
            inherit (host) system;
            specialArgs = {
              inherit inputs;
              my = my // host // { inherit hostname; };
            };
            modules = [
              inputs.chaotic.nixosModules.default
              (./hosts + "/${hostname}")
            ];
          }
        ) hosts;
      };
    };
}
