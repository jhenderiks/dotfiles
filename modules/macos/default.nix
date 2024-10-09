{ config, lib, pkgs, ... }:

{
  imports = [
    ./homebrew.nix
    ./shell.nix
    ./system.nix
  ];

  config = lib.mkIf pkgs.stdenv.isDarwin {
    environment.shells = [ pkgs.${config.cfg.shell} ];

    # environment.variables = { XDG_CONFIG_HOME = "~/.config"; };
    
    cfg.homeBase = "/Users";

    services.nix-daemon.enable = true;

    security.pam.enableSudoTouchIdAuth = true;
  };
}