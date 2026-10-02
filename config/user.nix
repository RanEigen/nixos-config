# 用户身份、工作区与跨作用域策略。
rec {
  username = "ran";
  homeDirectory = "/home/${username}";
  homeStateVersion = "24.05";
  repository = "${homeDirectory}/nixos-config";
  # 可选：nixd（Nixpkgs 包与系统选项）或 nil（基于源码推断）。
  nixLanguageServer = "nixd";
  gitEmail = "jackocksmic@outlook.com";
  nixpkgsConfig.allowUnfree = true;
  nixAccessTokensPath = "/run/nix-access-tokens";
  catppuccin = import ./theme.nix;
}
