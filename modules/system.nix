{ my, ... }:
{
  # 初次安装值，不随发行版升级。
  system.stateVersion = my.systemStateVersion;
  nixpkgs.config = my.nixpkgsConfig;
}
