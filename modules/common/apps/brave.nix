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
    macos.homebrew.casks = [ "brave-browser" ];
    nixos.environment.systemPackages = [ pkgs.brave ];
  };
}