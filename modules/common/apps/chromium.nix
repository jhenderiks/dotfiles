{ config, lib, pkgs, ... }:

{
  options = {
    chromium = {
      enable = lib.mkEnableOption {
        default = false;
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.ungoogled-chromium;
      };
      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };

  config = lib.mkIf config.chromium.enable {
    environment.systemPackages = [ config.chromium.package ];

    cfg.homeManagerShared.programs.chromium = {
      enable = true;
      package = config.chromium.package;
      extensions = config.chromium.extensions ++ [
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      ];
    };
  };
}