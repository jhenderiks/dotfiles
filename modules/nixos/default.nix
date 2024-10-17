{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
    inputs.home-manager.nixosModules.home-manager
    ./disk
    ./gnome.nix
    ./hyprland.nix
    ./kde.nix
  ];

  config = {
    _user.config.users = {
      isNormalUser = true;
      extraGroups = [ "docker" "wheel" ];
      hashedPassword = config._user.hashedPassword;
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;

    catppuccin.enable = true;

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    networking.networkmanager.enable = true;

    system.stateVersion = "24.11";

    time.timeZone = "America/Toronto"; # https://github.com/NixOS/nixpkgs/issues/68489

    users.mutableUsers = false;
  };
}