{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gh
  ];

  user.home-manager.programs.git = {
    enable = true;

    userName = lib.mkDefault "Justin Henderiks";
    userEmail = lib.mkDefault "jhenderiks@users.noreply.github.com";

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
      rebase.autosquash = "true";
    };
  };
}
