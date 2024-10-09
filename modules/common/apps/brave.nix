{ config, lib, pkgs, ... }:

{
  options = {
    brave = {
      enable = lib.mkEnableOption {
        default = false;
      };
    };
  };

  config = lib.mkIf config.brave.enable {
    chromium.enable = true;
    chromium.package = pkgs.brave;
  };
}