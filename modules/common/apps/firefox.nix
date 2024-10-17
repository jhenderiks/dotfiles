{ config, lib, pkgs, ... }:

{
  options = {
    firefox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.firefox.enable {
    macos.homebrew.casks = [ "firefox" ];
    # _nixos.user.home-manager.programs.firefox.enable = true;
    nixos.environment.systemPackages = [ pkgs.firefox ];
  };
}