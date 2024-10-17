{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    ./apps
    ./services
    ./shell
    ./options.nix
  ];

  config = {
    _user.config.home-manager = {
      imports = [
        inputs.catppuccin.homeManagerModules.catppuccin
      ];

      catppuccin.enable = true;

      home.stateVersion = "24.11";
    };

    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    nix.settings.experimental-features = "nix-command flakes";
  };
}