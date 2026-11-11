# 两个编辑器共用运行时绝对路径表达式（REF:2026-09-28-nixd-editor-completion）。
{
  hostConfig,
  system,
  pkgs,
}:
{
  formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
  nixpkgs.expr = "import (builtins.getFlake \"${hostConfig.configurationRepository}\").inputs.nixpkgs { system = \"${system}\"; }";
  options = {
    nixos.expr = "(builtins.getFlake \"${hostConfig.configurationRepository}\").nixosConfigurations.${hostConfig.hostName}.options";
    home-manager.expr = "(builtins.getFlake \"${hostConfig.configurationRepository}\").nixosConfigurations.${hostConfig.hostName}.options.home-manager.users.type.getSubOptions []";
  };
}
