{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    git
    gh
  ];

  home-manager.sharedModules = [
    {
      programs.git = {
        enable = true;

        settings = {
          init.defaultBranch = "main";
          push.autoSetupRemote = "true";
          rebase.autosquash = "true";

          user = {
            email = "${config.user.github.username}@users.noreply.github.com";
            name = "Justin Henderiks";
          };
        };
      };
    }
  ];
}
