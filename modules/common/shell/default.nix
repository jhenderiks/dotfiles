{ pkgs, ... }:

{
  imports = [
    ./starship
    ./bash.nix
    ./direnv.nix
    ./fish.nix
    ./git.nix
  ];

  environment.systemPackages = [ pkgs.neofetch ];
}
