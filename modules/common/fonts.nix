{ pkgs, ... }:

let
  monospace = "FiraCode Nerd Font";
in {
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  nixos.fonts.fontconfig.defaultFonts.monospace = [ monospace ];

  user.home-manager.fonts.fontconfig.defaultFonts.monospace = [ monospace ];
}
