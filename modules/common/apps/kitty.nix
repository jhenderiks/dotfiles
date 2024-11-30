{ config, lib, pkgs, ... }:

{
  options = {
    kitty = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.kitty.enable {
    environment.systemPackages = [ pkgs.kitty ];

    macos.user.home-manager.programs.kitty = {
      font.size = 16;
      settings = {
        # TODO: can do this by setting programs.kitty.darwinLaunchOptions?
        macos_traditional_fullscreen = true;
        macos_quit_when_last_window_closed = true;
      };
    };

    user.home-manager.programs.kitty = {
      enable = true;
      font.name = config.font.monospace;
    };
  };
}
