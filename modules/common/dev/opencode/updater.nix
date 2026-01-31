{
  config,
  lib,
  pkgs,
  ...
}:

let
  user = config.user.name;
  home = config.users.users.${user}.home;

  # Script to run for updates
  updateScript = pkgs.writeShellScript "opencode-update" ''
    export PATH="${
      lib.makeBinPath [
        pkgs.curl
        pkgs.jq
        pkgs.nix
        pkgs.gnused
        pkgs.gawk
        pkgs.coreutils
        pkgs.git
      ]
    }:$PATH"

    # Run the update script
    ${home}/.dotfiles/scripts/update-opencode.sh
  '';

  # Random hour for the timer to avoid thundering herd
  # Uses a simple hash of the username to deterministically pick a time (0-23)
  timerHour = builtins.toString (lib.mod (lib.stringLength user) 24);
in
{
  options.opencode.update = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.opencode.enable;
      description = "Whether to enable automatic daily updates for opencode. Defaults to true when opencode is enabled.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (config.opencode.update.enable && pkgs.stdenv.isLinux) {
      # NixOS: systemd user timer
      nixos.systemd.user.timers.opencode-update = {
        description = "Daily update check for opencode";

        timerConfig = {
          OnCalendar = "*-*-* ${timerHour}:00:00";
          Persistent = true;
          Unit = "opencode-update.service";
        };

        wantedBy = [ "timers.target" ];
      };

      nixos.systemd.user.services.opencode-update = {
        description = "Update opencode to latest version";

        serviceConfig = {
          Type = "oneshot";
          ExecStart = updateScript;
          # Only run if dotfiles repo exists
          ConditionPathExists = "${home}/.dotfiles";
        };

        # Environment setup
        environment = {
          HOME = home;
        };
      };
    })

    (lib.mkIf (config.opencode.update.enable && pkgs.stdenv.isDarwin) {
      # Darwin: launchd user agent
      macos.launchd.user.agents.opencode-update = {
        description = "Daily update check for opencode";

        serviceConfig = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            updateScript
          ];
          StartCalendarInterval = {
            Hour = lib.toInt timerHour;
            Minute = 0;
          };
          # Only run if dotfiles repo exists
          ConditionPathExists = "${home}/.dotfiles";
          StandardOutPath = "/tmp/opencode-update.log";
          StandardErrorPath = "/tmp/opencode-update.error.log";
          # Don't run if already running
          ThrottleInterval = 3600; # 1 hour
        };
      };
    })
  ];
}
