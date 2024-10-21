{ config, lib, pkgs, ... }:

let
  fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ config.font.monospace ];
    };
  };
  packages = with pkgs; [ fira-code ];
in {
  options = with lib; {
    font.monospace = mkOption {
      type = types.str;
      default = "Fira Code";
    };
  };

  config = {
    fonts.packages = packages;

    nixos.fonts.fontconfig = fontconfig;
    user.home-manager.fonts.fontconfig = fontconfig;
  };
}
