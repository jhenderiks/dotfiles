{ config, lib, pkgs, ... }:

{
  options = {
    gnome = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.gnome.enable {
    user.home-manager.dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
        "org/gnome/mutter".experimental-features = ["scale-monitor-framebuffer"];
      };
    };

    environment = {
      gnome.excludePackages = with pkgs; [
        gnome-tour
      ];

      systemPackages = with pkgs; [
        baobab
        cheese
        eog
        evince
        file-roller
        gnome-calculator
        gnome-disk-utility
        gnome-screenshot
        gnome-system-monitor
        gnomeExtensions.gtile
        nautilus
        simple-scan
      ];
    };

    services = {
      gnome.core-utilities.enable = false;
    
      xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;

        excludePackages = [ pkgs.xterm ];
      };
    };
  };
}