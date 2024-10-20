{ config, lib, pkgs, ... }:

{
  options = {
    zoom = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.zoom.enable {
    environment.systemPackages = [ pkgs.zoom-us ];
    unfreePackages = [ "zoom" ];
  };
}