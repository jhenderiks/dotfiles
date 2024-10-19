{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.starship ];

  user.home-manager.programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      
    };
  };
}
