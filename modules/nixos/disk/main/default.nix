{ config, options, lib, ... }:

let
  cfg = config.disk.main;
  ifDisabled = val: if cfg.enable then null else val; 
in {
  imports = [
    ./disko
    ./impermanence
  ];

  options = with lib; {
    disk.main = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      device = mkOption {
        type = types.str;
        default = ifDisabled "";
      };

      encrypted = mkOption {
        type = types.bool;
        default = ifDisabled false;
      };

      impermanence = {
        enable = mkOption {
          type = types.bool;
          default = ifDisabled false;
        };

        dir = mkOption {
          type = types.str;
          default = "/state";
        };
      };
    };
  };
}