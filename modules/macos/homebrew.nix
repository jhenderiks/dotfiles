{ config, lib, ... }:

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

    system.activationScripts.preActivation.text = ''
      if ! { /opt/homebrew/bin/brew -v > /dev/null; } 2>&1; then
        ${lib.concatMapStrings (user: ''
          if ! { /opt/homebrew/bin/brew -v > /dev/null; } 2>&1; then
            sudo -u ${user} env NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          fi
        '') config.user.usernames}
      fi
    '';
  };
}
