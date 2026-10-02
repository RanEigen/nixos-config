# 用户、登录 shell 与 sops 密码接线。
{
  config,
  pkgs,
  my,
  ...
}:
{
  users = {
    users.${my.username} = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
        "networkmanager"
        "podman"
        "input"
      ];
      # 密码必须在创建用户前解密（REF:2026-08-17-niri-login）。
      hashedPasswordFile = config.sops.secrets.user-password.path;
    };
    users.root.hashedPasswordFile = config.sops.secrets.root-password.path;
    mutableUsers = false;
  };
  programs.fish.enable = true;
}
