{ config, lib, pkgs, ... }:

{
  options = {
    steam = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.steam.enable {
    macos.homebrew.casks = [ "steam" ];
    nixos.programs.steam.enable = true;
    unfreePackages = [ "steam" "steam-original" ];
  };
}
