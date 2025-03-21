{ config, lib, pkgs, ... }:

{
  options = {
    telegram = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.telegram.enable {
    environment.systemPackages = [ pkgs.telegram-desktop ];
  };
}
