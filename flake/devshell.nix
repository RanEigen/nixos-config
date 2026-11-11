{ ... }:
{
  perSystem = { pkgs, ... }: {
    devShells = {
      default = pkgs.mkShell {
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
          gitleaks
          actionlint
          zizmor
          shfmt
          typos
          taplo
          just
        ];
      };
      # Each project remains responsible for selecting its compiler/runtime versions.
      rust-tools = pkgs.mkShell {
        packages = with pkgs; [
          cargo-nextest
          cargo-edit
          cargo-audit
        ];
      };
      go-tools = pkgs.mkShell {
        packages = with pkgs; [
          gopls
          gotestsum
          golangci-lint
          govulncheck
          delve
          go-tools
        ];
      };
      python-tools = pkgs.mkShell {
        packages = with pkgs; [
          uv
          ruff
          basedpyright
          python3
        ];
      };
      cpp-tools = pkgs.mkShell {
        packages = with pkgs; [ valgrind ];
      };
    };
  };
}
