{ config, lib, pkgs, ... }:

{
  imports = [
    ./nordvpn.nix
    ./syncthing.nix
  ];
}
