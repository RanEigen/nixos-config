# 秘密在运行时解密，不进入 Store。
{
  config,
  inputs,
  userConfig,
  hostConfig,
  ...
}:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;

    # 私钥必须放 / 下（开机早期可达），不能放 /home（子卷未挂载）(REF:2026-08-17-niri-login)
    age.keyFile = "/var/lib/sops-nix/keys.txt";

    # 秘密声明：neededForUsers 秘密必须在 users 创建前解密
    secrets = {
      github-token = { };
      user-password.neededForUsers = true;
      root-password.neededForUsers = true;
    };

    # 客户端解析 flake 输入也需要 token，由系统 nix.conf include 此只读片段。
    templates."nix-access-tokens" = {
      path = hostConfig.nixAccessTokensFile;
      content = "access-tokens = github.com=${config.sops.placeholder.github-token}";
      owner = userConfig.user.userName;
      mode = "0400";
    };
  };

  # 仅在缺失时预置空文件，避免 include 悬空；不覆盖 sops 生成物。
  systemd.tmpfiles.rules = [
    "f ${hostConfig.nixAccessTokensFile} 0400 ${userConfig.user.userName} users -"
  ];
}
