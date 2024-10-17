{ config, lib, pkgs, ... }:

{
  options = {
    kde = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.kde.enable {
    environment = {
      plasma6.excludePackages = with pkgs.kdePackages; [
        ark
        baloo-widgets # baloo information in Dolphin
        # dolphin
        # dolphin-plugins
        elisa
        ffmpegthumbs
        gwenview
        kate
        khelpcenter
        konsole
        krdp
        okular
        plasma-browser-integration
        (lib.getBin qttools) # Expose qdbus in PATH
        spectacle
        # xwaylandvideobridge # exposes Wayland windows to X11 screen capture
      ];
    };

    programs.dconf.enable = true;

    services = {
      xserver = {
        enable = true;
        excludePackages = [ pkgs.xterm ];
      };

      displayManager.sddm.enable = true;
      displayManager.sddm.wayland.enable = true;
      desktopManager.plasma6.enable = true;
    };
  };
}