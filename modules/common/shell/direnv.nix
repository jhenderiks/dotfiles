{ pkgs, ... }:

{
  user.home-manager.programs.direnv = {
    enable = true;
    package = pkgs.direnv;
    nix-direnv.enable = true;
    nix-direnv.package = pkgs.nix-direnv;
  };
}
