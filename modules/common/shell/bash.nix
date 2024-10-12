{ pkgs, ... }:

{
  _macos.programs.bash.enable = true;
  _user.config.home-manager.programs.bash.enable = true;
}