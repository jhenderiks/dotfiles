{ config, lib, pkgs, ... }:

let
  user = config.syncthing.user;
  home = config.users.users.${user}.home;
in {
  options = with lib; {
    syncthing = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      user = mkOption { type = types.str; };

      devices = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              id = mkOption { type = types.str; };
            };
          }
        );

        default = {};
      };

      folders = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              path = mkOption { type = types.str; };
              devices = mkOption { type = types.listOf types.str; };
            };
          }
        );

        default = {};
      };
    };
  };

  config = lib.mkIf config.syncthing.enable {
    # TODO: macos
    # https://github.com/nix-community/home-manager/pull/5616

    _nixos = {
      services.syncthing = {
        enable = true;
        user = user;
        dataDir = home;
        configDir = "${home}/.config/syncthing";
        overrideDevices = true;
        overrideFolders = true;
        settings = {
          devices = config.syncthing.devices;
          folders = config.syncthing.folders;
        };
      };

      systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
    };
  };
}