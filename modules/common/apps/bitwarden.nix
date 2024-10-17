{ config, lib, pkgs, ... }:

{
  options = {
    bitwarden = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.bitwarden.enable {
    macos.homebrew.casks = [ "bitwarden" ];
    nixos.environment.systemPackages = [ pkgs.bitwarden-desktop ];
    unfreePackages = [ "bitwarden" ];
  };
}