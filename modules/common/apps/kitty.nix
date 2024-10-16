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
    _user.config.home-manager.programs.kitty.enable = true;
    environment.systemPackages = [ pkgs.kitty ];
  };
}