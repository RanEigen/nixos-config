# NixOS / Home Manager 集成；具体桌面和开发工具由 profiles 选择。
{
  inputs,
  userConfig,
  hostConfig,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    # 避免启动期 D-Bus 竞态（REF:2026-08-17-niri-login）。
    startAsUserService = true;
    extraSpecialArgs = { inherit inputs userConfig hostConfig; };
    users.${userConfig.user.userName}.imports = [ ../home/home.nix ];
  };
  systemd.user.services.home-manager.wantedBy = [ "default.target" ];
}
