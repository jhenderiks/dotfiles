{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gh
  ];

  user.home-manager.programs.git = {
    enable = true;

    settings = {
      user.email = "${config.user.github.username}@users.noreply.github.com";
      user.name = "Justin Henderiks";
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
      rebase.autosquash = "true";
    };
  };
}
