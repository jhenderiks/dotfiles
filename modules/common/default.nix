{ config, lib, pkgs, ... }:

{
  imports = [
    ./apps
    ./shell
    ./user
  ];

  options = {
    cfg = lib.mkOption {
      type = lib.types.submodule {
        options = {
          homeBase = lib.mkOption {
            type = lib.types.str;
            default = "/home";
          };

          homeManagerShared = lib.mkOption {
            type = lib.types.submodule {
              options = {
                home = lib.mkOption { type = lib.types.attrs; };
                programs = lib.mkOption { type = lib.types.attrs; };
              };
            };
          };

          shell = lib.mkOption {
            type = lib.types.str;
            default = "fish";
          };

          unfreePackages = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
          };

          users = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "justin" ];
          };
        };
      };
    };
  };

  config = {
    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    nix.settings.experimental-features = "nix-command flakes";

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.cfg.unfreePackages;
  };
}