{ pkgs, ... }:

{
  programs.fish.enable = true;
  user.home-manager.programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
}