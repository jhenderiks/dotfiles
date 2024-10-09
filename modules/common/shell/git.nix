{ lib, options, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gh
  ];

  programs = lib.optionalAttrs (builtins.hasAttr "git" options.programs) {
    git.enable = true;
  };

  cfg.homeManagerShared.programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
      rebase.autosquash = "true";
    };
  };
}