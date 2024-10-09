{ config, pkgs, lib, ... }:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    cfg.homeManagerShared.home.sessionPath = [ "/opt/homebrew/bin" ];

    homebrew = {
      enable = true;

      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };
    };

    system.activationScripts.preUserActivation.text = ''
      if ! /opt/homebrew/bin/brew -v 2>&1 >/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    '';
  };
}