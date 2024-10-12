{ config, lib, pkgs, ... }:

{
  imports = [
    ./apps
    ./services
    ./shell
    ./options.nix
  ];

  config = {
    _user.config.home-manager = {
      home.stateVersion = "24.11";

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

    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    nix.settings.experimental-features = "nix-command flakes";
  };
}