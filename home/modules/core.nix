# 用户历史版本与 Nix 客户端策略。
{
  pkgs,
  lib,
  userConfig,
  ...
}:
{
  home.homeDirectory = userConfig.user.homeDirectory;
  home.stateVersion = userConfig.user.homeManagerStateVersion;
  programs.home-manager.enable = true;
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  # 系统 nix.conf 提供缓存、超时与秘密 include；此处仅输出用户包策略。
  xdg.configFile."nixpkgs/config.nix".text = lib.generators.toPretty { } userConfig.nix.nixpkgsConfig;
}
