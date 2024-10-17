{ config, inputs, lib, options, pkgs, ... }:

let
  macosConfig = builtins.mapAttrs (
    name: value: config.macos.${name}
  ) options.macos;
in {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.mac-app-util.darwinModules.default
    ./homebrew.nix
    ./keyboard.nix
    ./shell.nix
    ./system.nix
  ];

  config = lib.mkMerge [
    macosConfig
    {
      # environment.variables = { XDG_CONFIG_HOME = "~/.config"; };
      
      user.homeBase = lib.mkForce "/Users";

      security.pam.enableSudoTouchIdAuth = true;

      services.nix-daemon.enable = true;

      system.stateVersion = 5;
    }
  ];
}