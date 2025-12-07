{
  config,
  lib,
  pkgs,
  ...
}:

let
  fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ config.font.monospace ];
    };
  };
  packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
  ];
in
{
  options = with lib; {
    font.monospace = mkOption {
      type = types.str;
      default = "Fira Code";
    };

    font.monospaceNerdFont = mkOption {
      type = types.str;
      default = "FiraCode Nerd Font";
    };
  };

  config = {
    fonts.packages = packages;

    home-manager.sharedModules = [ { fonts.fontconfig = fontconfig; } ];

    nixos.fonts.fontconfig = fontconfig;

    stylix = {
      enable = true;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/framer.yaml";
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/classic-dark.yaml";
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/embers.yaml";
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyodark.yaml";
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";

      fonts = {
        monospace = {
          name = config.font.monospace;
          # package = pkgs.nerd-fonts.fira-code;
        };
      };

      image = config.lib.stylix.pixel "base02";
    };
  };
}
