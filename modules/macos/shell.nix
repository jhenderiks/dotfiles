{
  config,
  lib,
  pkgs,
  ...
}:

let
  chshFile = "/tmp/chsh.sh";
  user = config.user.name;
  shellPath = "/run/current-system/sw/bin/${config.user.shell}";
  chshScript = ''
    #!/bin/sh
    max_retry=3
    counter=0
    rm ${chshFile}
    until sudo -u ${user} chsh -s ${shellPath} ${user}
    do
      ((counter++))
      [[ counter -eq \$max_retry ]] && echo "Failed" && exit 1
      echo "Try again"
    done
  '';
in
{
  config = {
    programs.bash.enable = true;
    programs.zsh.enable = true;

    home-manager.sharedModules = [ { programs.zsh.enable = true; } ];

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
