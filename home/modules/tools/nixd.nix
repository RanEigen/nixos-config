# 两个编辑器共用运行时绝对路径表达式（REF:2026-09-28-nixd-editor-completion）。
{
  my,
  system,
  pkgs,
}:
{
  formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
  nixpkgs.expr = "import (builtins.getFlake \"${my.repository}\").inputs.nixpkgs { system = \"${system}\"; }";
  options = {
    nixos.expr = "(builtins.getFlake \"${my.repository}\").nixosConfigurations.${my.hostname}.options";
    home-manager.expr = "(builtins.getFlake \"${my.repository}\").nixosConfigurations.${my.hostname}.options.home-manager.users.type.getSubOptions []";
  };
}
