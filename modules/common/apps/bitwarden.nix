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
    _macos.homebrew.casks = [ "bitwarden" ];
    _nixos.environment.systemPackages = [ pkgs.bitwarden-desktop ];
    _unfreePackages = [ "bitwarden" ];
  };
}