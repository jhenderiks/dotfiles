{ config, lib, pkgs, ... }:

{
  options = {
    spotify = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.spotify.enable {
    _macos.homebrew.casks = [ "spotify" ];
    _nixos.environment.systemPackages = [ pkgs.spotify ];
    _unfreePackages = [ "spotify" ];
  };
}