{ config, lib, pkgs, ... }: 

let
  chshFile = "/tmp/chsh.sh";
  chshScript = ''
    #!/bin/sh
    max_retry=3
    counter=0
    rm ${chshFile}
    ${(
      lib.concatMapStrings (
        user: ''
          until sudo -u ${user} chsh -s ${shellPath} ${user}
          do
            ((counter++))
            [[ counter -eq \$max_retry ]] && echo "Failed" && exit 1
            echo "Try again"
          done
        ''
      ) config._user.users
    )}
  '';
  shellPath = "/run/current-system/sw/bin/${config._user.shell}";
in {
  config = {
    programs.zsh.enable = true;

    _user.config.home-manager = {
      programs.zsh.enable = true;

      programs.kitty.settings = {
        # TODO: can do this by setting programs.kitty.darwinLaunchOptions?
        macos_traditional_fullscreen = true;
        macos_quit_when_last_window_closed = true;
      };
    };

    system.activationScripts.postUserActivation.text = lib.concatStringsSep "\n" [
      "if [ \"$SHELL\" != \"${shellPath}\" ]; then"
      "cat <<- EOF > ${chshFile}"
      chshScript
      "EOF"
      "chmod +x ${chshFile}"
      "fi"
    ];

    system.activationScripts.postActivation.text = ''
      if [ -f "${chshFile}" ]; then
        exec ${chshFile}
      fi
    '';
  };
}
