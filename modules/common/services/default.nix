{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./displaylink.nix
    ./nordvpn.nix
    ./sunshine.nix
    ./syncthing.nix
  ];
}
