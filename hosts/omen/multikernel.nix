# 备用内核；NVIDIA 驱动随 boot.kernelPackages 配套。
{ pkgs, ... }:
{
  specialisation = {
    latest.configuration.boot.kernelPackages = pkgs.linuxPackages_latest;
    lts.configuration.boot.kernelPackages = pkgs.linuxPackages_6_12;
  };
}
