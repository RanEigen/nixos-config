{ userConfig, hostConfig, ... }:
{
  # 初次安装值，不随发行版升级。
  system.stateVersion = hostConfig.nixosStateVersion;
  nixpkgs.config = userConfig.nix.nixpkgsConfig;
}
