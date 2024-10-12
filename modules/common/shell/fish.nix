{ pkgs, ... }:

{
  programs.fish.enable = true;
  _user.config.home-manager.programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
}