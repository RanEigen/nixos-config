# Zed language servers and shared language preferences.
{
  pkgs,
  userConfig,
  hostConfig,
  lib,
  ...
}:
let
  languageSettings = import ./language-settings.nix {
    inherit
      lib
      pkgs
      userConfig
      hostConfig
      ;
  };
in
{
  programs.zed-editor = {
    enable = true;
    extensions = languageSettings.zedExtensions;
    userSettings = languageSettings.zedSettings;
  };
}
