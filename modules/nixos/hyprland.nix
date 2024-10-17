{ config, lib, pkgs, ... }:

{
  options = {
    hyprland = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.hyprland.enable {
    # _user.config.home-manager = {
    #   home.sessionVariables.NIXOS_OZONE_WL = "1";
    #   wayland.windowManager.hyprland.enable = true;
    # };

    programs.hyprland.enable = true;
  };
}