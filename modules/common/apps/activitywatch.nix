{
  config,
  lib,
  pkgs,
  ...
}:

let
  awWebChromiumExtensionId = "nglaklhklhcoonedhgnpgddginnjdadi";
  awWebFirefoxExtensionId = "{ef87d84c-2127-493f-b952-5b4e744245bc}";
  sessionTarget =
    if config ? niri && config.niri.enable then "niri.service" else "graphical-session.target";
in
{
  options = {
    activitywatch = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.activitywatch.enable {
    chromium.extensions = [ awWebChromiumExtensionId ];

    nixos.environment.systemPackages = [
      pkgs.activitywatch
      pkgs.awatcher
    ];

    nixos.programs.chromium = {
      enable = true;
      extensions = [ "${awWebChromiumExtensionId};https://clients2.google.com/service/update2/crx" ];
    };

    nixos.programs.firefox.policies.ExtensionSettings.${awWebFirefoxExtensionId} =
      lib.mkIf config.firefox.enable
        {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/aw-watcher-web/latest.xpi";
        };

    nixos.systemd.user.services.activitywatch-server = {
      description = "ActivityWatch server";
      wantedBy = [ "default.target" ];

      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkgs.activitywatch}/bin/aw-server --host 127.0.0.1 --port 5600";
        Restart = "always";
        RestartSec = "5s";
      };
    };

    nixos.systemd.user.services.activitywatch-awatcher = {
      description = "ActivityWatch window and idle watcher";
      wantedBy = [ sessionTarget ];
      bindsTo = [ sessionTarget ];
      partOf = [ sessionTarget ];
      after = [
        sessionTarget
        "activitywatch-server.service"
      ];
      wants = [ "activitywatch-server.service" ];

      serviceConfig = {
        Type = "exec";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
        ExecStart = "${pkgs.awatcher}/bin/awatcher --host 127.0.0.1 --port 5600";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
