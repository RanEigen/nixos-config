{
  # Keep namespaces aligned with their canonical source files; do not flatten.
  user = import ./user.nix;
  preferences = import ./preferences.nix;
  nix = import ./nix-settings.nix;
}
