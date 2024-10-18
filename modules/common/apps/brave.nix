{ config, lib, pkgs, ... }:

{
  options = {
    brave = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.brave.enable {
    chromium = {
      enable = true;
      package = pkgs.brave;
    };
  };
}
