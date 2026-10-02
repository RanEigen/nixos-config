# NixOS / Home Manager 集成；具体桌面和开发工具由 profiles 选择。
{ inputs, my, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    # 避免启动期 D-Bus 竞态（REF:2026-08-17-niri-login）。
    startAsUserService = true;
    extraSpecialArgs = { inherit inputs my; };
    users.${my.username}.imports = [ ../home/home.nix ];
  };
  systemd.user.services.home-manager.wantedBy = [ "default.target" ];
}
