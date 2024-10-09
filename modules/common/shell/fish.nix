{ pkgs, ... }:

{
  programs.fish.enable = true;

  cfg.homeManagerShared.programs.fish.enable = true;
}