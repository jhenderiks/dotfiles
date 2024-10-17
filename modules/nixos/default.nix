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

      xdg = {
        enable = true;

        userDirs = {
          enable = true;
          createDirectories = true;
          desktop = "$HOME/desktop";
          documents = "$HOME/docs";
          download = "$HOME/downloads";
          music = "$HOME/media/music";
          pictures = "$HOME/media/images";
          publicShare = "$HOME/public";
          templates = "$HOME/templates";
          videos = "$HOME/media/videos";
          extraConfig = {
            XDG_DEV_DIR = "$HOME/dev";
          };
        };
      };
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