{ config, lib, pkgs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.mac-app-util.darwinModules.default
    ./homebrew.nix
    ./shell.nix
    ./system.nix
  ];

  config = {
    # environment.variables = { XDG_CONFIG_HOME = "~/.config"; };
    
    _user.homeBase = lib.mkForce "/Users";

    security.pam.enableSudoTouchIdAuth = true;

    services.nix-daemon.enable = true;

    system.stateVersion = 5;
  };
}