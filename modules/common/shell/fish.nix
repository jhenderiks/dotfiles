{ pkgs, ... }:

{
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
  home-manager.sharedModules = [ { programs.fish.enable = true; } ];
}
