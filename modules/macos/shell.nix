{ config, lib, ... }:

let shellPath = "/run/current-system/sw/bin/${config.user.shell}";
in {
  config = {
    programs.bash.enable = true;
    programs.zsh.enable = true;

    user.home-manager = {
      programs.zsh.enable = true;

      programs.kitty = {
        settings = {
          # TODO: can do this by setting programs.kitty.darwinLaunchOptions?
          macos_traditional_fullscreen = true;
          macos_quit_when_last_window_closed = true;
        };
      };
    };

    system.activationScripts.postActivation.text = ''
      ${lib.concatMapStrings (user: ''
        currentShell="$(dscl . -read /Users/${user} UserShell 2>/dev/null | awk '{print $2}')"
        if [ "$currentShell" != "${shellPath}" ]; then
          chsh -s "${shellPath}" "${user}"
        fi
      '') config.user.usernames}
    '';
  };
}
