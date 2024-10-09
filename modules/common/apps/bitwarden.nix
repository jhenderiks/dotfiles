{ config, lib, pkgs, ... }:

{
  options = {
    bitwarden = {
      enable = lib.mkEnableOption {
        default = false;
      };
    };
  };

  config = lib.mkIf config.bitwarden.enable (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      environment.systemPackages = with pkgs; [ bitwarden-desktop ];
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      homebrew.casks = [ "bitwarden" ];
    })
    {
      chromium.extensions = [ "nngceckbapebfimnlniiiahkandclblb" ];
    }
  ]);
}