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
    _macos.homebrew.casks = [ "brave-browser" ];
    _nixos.environment.systemPackages = [ pkgs.brave ];
  };
}