{ inputs, my }:
{
  perSystem = { system, pkgs, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = my.nixpkgsConfig;
    };
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        nixd
        nixfmt
        statix
        deadnix
        treefmt
        nurl
        nix-fast-build
        nixpkgs-review
        nixpkgs-hammering
        nix-diff
        python3
      ];
    };
  };
}
