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

  config = lib.mkIf config.spotify.enable (
    lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isDarwin {
        macos.homebrew.casks = [ "spotify" ];
      })
      (lib.mkIf pkgs.stdenv.isLinux {
        environment.systemPackages = [ pkgs.spotify ];
        unfreePackages = [ "spotify" ];
      })
    ]
  );
}
