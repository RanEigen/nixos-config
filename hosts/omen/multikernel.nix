# 标准内核为默认启动；Zen 与 CachyOS 可从启动菜单直接切换。
{ pkgs, ... }:
{
  specialisation.zen.configuration.boot.kernelPackages = pkgs.linuxPackages_zen;
  specialisation.cachyos.configuration.boot.kernelPackages = pkgs.linuxPackages_cachyos;
}
