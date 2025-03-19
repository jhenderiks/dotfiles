{ pkgs, ... }:

{
  imports = [ ./starship ./bash.nix ./direnv.nix ./fish.nix ./git.nix ];

  environment.shellAliases.k = "kubectl";

  environment.systemPackages = [ pkgs.neofetch ];
}
