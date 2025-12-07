{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./nordvpn.nix
    ./sunshine.nix
    ./syncthing.nix
  ];
}
