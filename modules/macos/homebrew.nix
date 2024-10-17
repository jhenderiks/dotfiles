{ config, pkgs, lib, ... }:

{
  config = {
    user.home-manager.home.sessionPath = [ "/opt/homebrew/bin" ];

    homebrew = {
      enable = true;

      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };

      casks = config.macos.homebrew.casks;
    };

    system.activationScripts.preUserActivation.text = ''
      if ! /opt/homebrew/bin/brew -v 2>&1 >/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    '';
  };
}