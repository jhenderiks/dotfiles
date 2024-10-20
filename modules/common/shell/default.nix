{ pkgs, ... }:

{
  imports = [
    ./starship
    ./bash.nix
    ./fish.nix
    ./git.nix
  ];

  environment.systemPackages = [ pkgs.neofetch ];
}
