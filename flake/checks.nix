{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      withoutPrivate = inputs.self.nixosConfigurations.omen.extendModules {
        modules = [ { disabledModules = [ ../hosts/omen/proxy/fcclient.nix ]; } ];
      };
      user = import ../config/user.nix;
      privateHome = withoutPrivate.config.home-manager.users.${user.username};
      base = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          my = user // {
            hostname = "check-base";
            hostId = "00000001";
            systemStateVersion = "25.05";
          };
        };
        modules = [
          ../profiles/base.nix
          {
            boot.loader.grub.enable = false;
            fileSystems."/" = {
              device = "none";
              fsType = "tmpfs";
            };
          }
        ];
      };
    in
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        settings.excludes = [ "**/hardware-configuration.nix" ];
      };
      pre-commit.settings = {
        excludes = [ ".*hardware-configuration\\.nix$" ];
        hooks = {
          deadnix.enable = true;
          statix = {
            enable = true;
            settings.ignore = [ "hardware-configuration.nix" ];
          };
        };
      };
      checks = {
        architecture = pkgs.runCommand "architecture-check" { nativeBuildInputs = [ pkgs.python3 ]; } ''
          python ${../scripts/check-architecture.py} ${inputs.self}
          touch "$out"
        '';
        # 求值移除私有客户端后的组合，不安装或运行客户端。
        proxy-without-fcclient =
          assert !lib.hasInfix "fcclient" withoutPrivate.config.services.dae.config;
          assert !(privateHome.home.sessionVariables ? fcproxy_port);
          assert
            !(builtins.elem "com.fcclient.app" privateHome.programs.noctalia.settings.widget.tray.pinned);
          assert builtins.elem pkgs.clash-verge-rev privateHome.home.packages;
          builtins.deepSeq withoutPrivate.config.system.build.toplevel.drvPath (
            pkgs.runCommand "proxy-without-fcclient-check" { } ''touch "$out"''
          );
        # 验证基础组合可独立求值，不隐含桌面、Btrfs 或主机私有网络。
        base-profile =
          assert !base.config.services.dae.enable;
          assert base.config.services.snapper.configs == { };
          assert !base.config.i18n.inputMethod.enable;
          assert !base.config.boot.loader.limine.enable;
          assert !(base.config.programs.umbriel.enable or false);
          builtins.deepSeq base.config.system.build.toplevel.drvPath (
            pkgs.runCommand "base-profile-check" { } ''touch "$out"''
          );
      };
    };
}
