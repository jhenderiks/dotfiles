{ config, lib, pkgs, ... }:

{
  options = {
    kitty = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.kitty.enable {
    environment.systemPackages = [ pkgs.kitty ];
    user.home-manager.programs.kitty.enable = true;
  };
}