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
    _macos.homebrew.casks = [ "firefox" ];
    _nixos.programs.firefox.enable = true;
    _nixos._user.config.home-manager.programs.firefox.enable = true;
  };
}