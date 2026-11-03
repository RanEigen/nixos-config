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
      user = import ../config/user.nix;
      host = inputs.self.nixosConfigurations.omen.config;
      desktopHome = host.home-manager.users.${user.username};
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
        # 检查手写的日常缩写及要求保留的插件，不执行任何展开命令。
        shell-shortcuts =
          pkgs.runCommand "shell-shortcuts-check"
            {
              nativeBuildInputs = [
                pkgs.fish
                pkgs.python3
              ];
            }
            ''
              export HOME="$TMPDIR/home"
              mkdir -p "$HOME"
              python ${../scripts/check-shell.py} ${
                pkgs.writeText "shell-shortcuts.json" (
                  builtins.toJSON {
                    functionNames = builtins.attrNames desktopHome.programs.fish.functions;
                    abbrs = desktopHome.programs.fish.shellAbbrs;
                    aliases = desktopHome.programs.fish.shellAliases;
                    plugins = map (plugin: plugin.name) desktopHome.programs.fish.plugins;
                  }
                )
              }
              touch "$out"
            '';
        # 使用所装合成器校验主配置和主机 include；不读取宿主机 ~/.config。
        umbriel-config =
          assert desktopHome.programs.noctalia.systemd.enable;
          assert !(builtins.elem "noctalia" desktopHome.programs.umbriel.settings.general.autostart);
          assert desktopHome.services.wlsunset.enable;
          assert desktopHome.services.wlsunset.duration == null;
          assert desktopHome.services.wlsunset.systemdTarget == desktopHome.wayland.systemd.target;
          assert
            desktopHome.programs.umbriel.settings.environment.QS_ICON_THEME == desktopHome.gtk.iconTheme.name;
          assert builtins.elem "machine.toml" desktopHome.programs.umbriel.settings.include.optional.files;
          pkgs.runCommand "umbriel-config-check" { } ''
            mkdir config
            cp ${desktopHome.xdg.configFile."umbriel/config.toml".source} config/config.toml
            cp ${desktopHome.xdg.configFile."umbriel/machine.toml".source} config/machine.toml
            chmod u+w config/machine.toml
            ${lib.getExe host.programs.umbriel.package} config validate -c "$PWD/config/config.toml"

            # 反向测试：include 中的未知表必须被发现，不能静默漏检主机配置。
            printf '\n[umbriel_check_invalid]\ninvalid = true\n' >> config/machine.toml
            if ${lib.getExe host.programs.umbriel.package} config validate \
              -c "$PWD/config/config.toml" > invalid.log 2>&1; then
              echo "Umbriel validation failed to reject an invalid machine include" >&2
              exit 1
            fi
            grep -Fq 'umbriel_check_invalid' invalid.log
            touch "$out"
          '';
        architecture = pkgs.runCommand "architecture-check" { nativeBuildInputs = [ pkgs.python3 ]; } ''
          python ${../scripts/check-architecture.py} ${inputs.self}
          touch "$out"
        '';
        # Clash Verge 的系统包由 NixOS 模块提供，不重复放入 Home Manager。
        proxy-client =
          assert host.programs.clash-verge.enable;
          assert host.programs.clash-verge.package == pkgs.clash-verge-rev;
          assert !(desktopHome.home.sessionVariables ? fcproxy_port);
          pkgs.runCommand "proxy-client-check" { } ''touch "$out"'';
        # 验证基础组合可独立求值，不隐含桌面、Btrfs 或主机私有网络。
        base-profile =
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
