{ pkgs, ... }:

{
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
  user.home-manager.programs.fish.enable = true;
}
