{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gh
  ];

  _nixos.programs.git.enable = true;

  _user.config.home-manager.programs.git = {
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
