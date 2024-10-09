{ config, lib, pkgs, ... }:

{
  options = {
    kitty = {
      enable = lib.mkEnableOption {
        default = false;
      };
    };
  };

  config = lib.mkIf config.kitty.enable {
    environment.systemPackages = with pkgs; [ kitty ];
  };
}