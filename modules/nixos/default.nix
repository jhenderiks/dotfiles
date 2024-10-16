{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
    inputs.home-manager.nixosModules.home-manager
    ./disk
    ./gnome.nix
  ];

  config = {
    _user.config.users = {
      isNormalUser = true;
      extraGroups = [ "docker" "wheel" ];
      hashedPassword = config._user.hashedPassword;
    };

    catppuccin.enable = true;

    system.stateVersion = "24.11";

    time.timeZone = "America/Toronto"; # https://github.com/NixOS/nixpkgs/issues/68489

    users.mutableUsers = false;
  };
}