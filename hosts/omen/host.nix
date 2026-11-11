# Facts and runtime paths for this NixOS installation.
{ userConfig }:
{
  hostName = "omen";
  system = "x86_64-linux";
  hostId = "007f0200";
  nixosStateVersion = "25.05";

  configurationRepository = "${userConfig.user.homeDirectory}/nixos-config";
  nixAccessTokensFile = "/run/nix-access-tokens";
}
