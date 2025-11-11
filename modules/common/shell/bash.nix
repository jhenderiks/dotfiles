{ pkgs, ... }:

{
  home-manager.sharedModules = [ { programs.bash.enable = true; } ];
}
