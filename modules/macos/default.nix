{ config, lib, pkgs, ... }:

{
  imports = [
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