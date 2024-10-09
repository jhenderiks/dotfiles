{ config, lib, pkgs, ... }:

{
  options = {
    spotify = {
      enable = lib.mkEnableOption {
        default = false;
      };
    };
  };

  config = lib.mkIf config.spotify.enable (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      environment.systemPackages = with pkgs; [ spotify ];

      cfg.unfreePackages = [ "spotify" ];
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      homebrew.casks = [ "spotify" ];
    })
  ]);
}