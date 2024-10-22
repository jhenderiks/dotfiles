{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gh
  ];

  user.home-manager.programs.git = {
    enable = true;

    userEmail = "${config.user.github.username}@users.noreply.github.com";
    userName = "Justin Henderiks";

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
      rebase.autosquash = "true";
    };
  };
}
