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
    # macos.homebrew.casks = [ "spotify" ];
    # nixos.environment.systemPackages = [ pkgs.spotify ];
    environment.systemPackages = [ pkgs.spotify ];
    unfreePackages = [ "spotify" ];
  };
}