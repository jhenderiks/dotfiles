{ config, lib, pkgs, ... }:

{
  imports = [
    ./disk
    ./gnome.nix
  ];

  config = {
    _user.config.users = {
      isNormalUser = true;
      extraGroups = [ "docker" "wheel" ];
      hashedPassword = config._user.hashedPassword;
    };

    system.stateVersion = "24.11";

    time.timeZone = "America/Toronto"; # https://github.com/NixOS/nixpkgs/issues/68489

    users.mutableUsers = false;
  };
}