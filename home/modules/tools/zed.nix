# Zed language servers and shared language preferences.
{
  pkgs,
  my,
  lib,
  ...
}:
let
  languageSettings = import ./language-settings.nix { inherit lib pkgs my; };
in
{
  programs.zed-editor = {
    enable = true;
    extensions = languageSettings.zedExtensions;
    userSettings = languageSettings.zedSettings;
  };
}
