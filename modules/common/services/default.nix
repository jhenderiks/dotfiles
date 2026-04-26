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
    ./stt.nix
    ./sunshine.nix
    ./syncthing.nix
  ];
}
