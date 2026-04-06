{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  options = {
    niri = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.niri.enable {

    programs.niri = {
      enable = true;
      package = inputs.niri.packages.${pkgs.system}.niri-unstable.overrideAttrs (_: {
        doCheck = false;
      });
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
          user = "greeter";
        };
      };
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "niri-kill-focused" ''
        pid=$(niri msg focused-window 2>/dev/null | grep -oP 'PID: \K[0-9]+')
        [ -n "$pid" ] && kill -9 "$pid"
      '')
      blueman
      brightnessctl
      btop
      nemo
      fuzzel
      imv
      mako
      mpv

      networkmanagerapplet
      pavucontrol
      playerctl
      celluloid
      polkit_gnome
      qalculate-gtk
      swappy
      waybar
      wdisplays
      wl-clipboard
      xarchiver
      zathura
    ];

    home-manager.sharedModules =
      let
        nerdFont = config.font.monospaceNerdFont;
        colors = config.lib.stylix.colors;
      in
      [
        (
          { config, ... }:
          {
            programs.waybar = {
              enable = true;
              settings.mainBar = {
                layer = "top";
                position = "top";
                spacing = 0;
                margin-top = 4;
                margin-left = 8;
                margin-right = 8;
                modules-left = [ "niri/workspaces" ];
                modules-center = [ "clock" ];
                modules-right = [
                  "idle_inhibitor"
                  "pulseaudio"
                  "backlight"
                  "network"
                  "battery"
                  "tray"
                ];
                "niri/workspaces" = {
                  format = "{icon}";
                  format-icons = {
                    active = "";
                    default = "";
                  };
                };
                clock = {
                  format = "{:%a %b %d  %H:%M}";
                  tooltip-format = "<tt>{calendar}</tt>";
                };
                idle_inhibitor = {
                  format = "{icon}";
                  format-icons = {
                    activated = "󰅶";
                    deactivated = "󰾪";
                  };
                };
                pulseaudio = {
                  format = "{icon} {volume}%";
                  format-muted = "󰝟";
                  format-icons.default = [
                    "󰕿"
                    "󰖀"
                    "󰕾"
                  ];
                  on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                  scroll-step = 5;
                };
                backlight = {
                  format = "󰃠 {percent}%";
                };
                network = {
                  format-wifi = "󰤨 {essid}";
                  format-ethernet = "󰈀";
                  format-disconnected = "󰤭";
                  tooltip-format = "{ifname}: {ipaddr}/{cidr}";
                };
                battery = {
                  format = "{icon} {capacity}%";
                  format-charging = "󰂄 {capacity}%";
                  format-icons = [
                    "󰂎"
                    "󰁺"
                    "󰁻"
                    "󰁼"
                    "󰁽"
                    "󰁾"
                    "󰁿"
                    "󰂀"
                    "󰂁"
                    "󰂂"
                    "󰁹"
                  ];
                  states = {
                    warning = 20;
                    critical = 10;
                  };
                };
                tray = {
                  spacing = 8;
                };
              };
              style = ''
                * {
                  font-family: "${nerdFont}", monospace;
                  font-size: 13px;
                  min-height: 0;
                }

                window#waybar {
                  background: rgba(0, 0, 0, 0.0);
                }

                .modules-left,
                .modules-center,
                .modules-right {
                  background: alpha(@base00, 0.85);
                  border-radius: 12px;
                  padding: 0 4px;
                }

                #workspaces button {
                  padding: 4px 8px;
                  border-radius: 10px;
                  color: @base05;
                  background: transparent;
                  border: none;
                }

                #workspaces button.active {
                  color: @base06;
                  background: alpha(@base02, 0.8);
                }

                #clock,
                #idle_inhibitor,
                #pulseaudio,
                #backlight,
                #network,
                #battery,
                #tray {
                  padding: 4px 10px;
                  border-radius: 10px;
                  color: @base05;
                }

                #battery.warning {
                  color: @base09;
                }

                #battery.critical {
                  color: @base08;
                }
              '';
            };

            programs.swaylock.enable = true;

            services.swayidle = {
              enable = true;
              timeouts = [
                {
                  timeout = 300;
                  command = "swaylock -f";
                }
                {
                  timeout = 600;
                  command = "niri msg action power-off-monitors";
                  resumeCommand = "niri msg action power-on-monitors";
                }
                {
                  timeout = 900;
                  command = "systemctl suspend";
                }
              ];
              events = {
                before-sleep = "swaylock -f";
              };
            };

            programs.fuzzel.enable = true;

            services.kanshi = {
              enable = true;
              systemdTarget = "niri.service";
              settings = [
                {
                  profile.name = "laptop";
                  profile.outputs = [
                    {
                      criteria = "eDP-1";
                      status = "enable";
                      scale = 2.0;
                    }
                  ];
                }
                {
                  profile.name = "triple";
                  profile.outputs = [
                    {
                      criteria = "DP-3";
                      status = "enable";
                      scale = 1.0;
                      position = "0,360";
                      mode = "1920x1080@60.000Hz";
                    }
                    {
                      criteria = "DP-4";
                      status = "enable";
                      scale = 1.0;
                      position = "1920,0";
                      mode = "2560x1440@59.951Hz";
                    }
                    {
                      criteria = "eDP-1";
                      status = "enable";
                      scale = 2.0;
                      position = "4480,0";
                    }
                  ];
                }
                {
                  profile.name = "all";
                  profile.outputs = [
                    {
                      criteria = "DP-3";
                      status = "enable";
                      scale = 1.0;
                      position = "1440,360";
                      mode = "1920x1080@60.000Hz";
                    }
                    {
                      criteria = "DP-4";
                      status = "enable";
                      scale = 1.0;
                      position = "3360,0";
                      mode = "2560x1440@59.951Hz";
                    }
                    {
                      criteria = "eDP-1";
                      status = "enable";
                      scale = 2.0;
                      position = "5920,0";
                    }
                    {
                      criteria = "DVI-I-2";
                      status = "enable";
                      scale = 1.5;
                      position = "2720,1440";
                      mode = "1920x1280@60.000Hz";
                    }
                    {
                      criteria = "DVI-I-1";
                      status = "enable";
                      scale = 1.5;
                      position = "4000,1440";
                      mode = "1920x1280@60.000Hz";
                    }
                  ];
                }
              ];
            };

            programs.niri.settings = {
              spawn-at-startup = [
                { command = [ "waybar" ]; }
                { command = [ "mako" ]; }
                { command = [ "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" ]; }
              ];

              input.touchpad = {
                tap = true;
                natural-scroll = true;
              };

              layout = {
                gaps = 4;
                preset-column-widths = [
                  { proportion = 1.0 / 3.0; }
                  { proportion = 1.0 / 2.0; }
                  { proportion = 2.0 / 3.0; }
                ];
                default-column-width.proportion = 1.0 / 2.0;
                border = lib.mkForce {
                  enable = true;
                  width = 1;
                  active.gradient = {
                    from = "#${colors.base0D}";
                    to = "#${colors.base0E}";
                    angle = 135;
                  };
                  inactive.color = "#${colors.base03}";
                };
                focus-ring.enable = lib.mkForce false;
              };

              prefer-no-csd = true;

              window-rules = [
                {
                  geometry-corner-radius =
                    let
                      r = 12.0;
                    in
                    {
                      top-left = r;
                      top-right = r;
                      bottom-left = r;
                      bottom-right = r;
                    };
                  clip-to-geometry = true;
                }
              ];

              hotkey-overlay.skip-at-startup = true;

              binds = with config.lib.niri.actions; {
                # Help
                "Mod+Shift+Slash".action = show-hotkey-overlay;

                # Launch
                "Mod+T".action = spawn "ghostty";
                "Mod+D".action = spawn "fuzzel";
                "Mod+Q".action = close-window;
                "Mod+Shift+Q".action = spawn "niri-kill-focused";
                "Super+Alt+L".action = spawn "swaylock";

                # Focus
                "Mod+H".action = focus-column-left;
                "Mod+J".action = focus-window-down;
                "Mod+K".action = focus-window-up;
                "Mod+L".action = focus-column-right;
                "Mod+Left".action = focus-column-left;
                "Mod+Down".action = focus-window-down;
                "Mod+Up".action = focus-window-up;
                "Mod+Right".action = focus-column-right;
                "Mod+Home".action = focus-column-first;
                "Mod+End".action = focus-column-last;

                # Move window/column
                "Mod+Ctrl+H".action = move-column-left;
                "Mod+Ctrl+J".action = move-window-down;
                "Mod+Ctrl+K".action = move-window-up;
                "Mod+Ctrl+L".action = move-column-right;
                "Mod+Ctrl+Left".action = move-column-left;
                "Mod+Ctrl+Down".action = move-window-down;
                "Mod+Ctrl+Up".action = move-window-up;
                "Mod+Ctrl+Right".action = move-column-right;
                "Mod+Ctrl+Home".action = move-column-to-first;
                "Mod+Ctrl+End".action = move-column-to-last;

                # Focus monitor
                "Mod+Shift+H" = {
                  action = focus-monitor-left;
                  hotkey-overlay.title = "Focus Monitor Left";
                };
                "Mod+Shift+J" = {
                  action = focus-monitor-down;
                  hotkey-overlay.title = "Focus Monitor Down";
                };
                "Mod+Shift+K" = {
                  action = focus-monitor-up;
                  hotkey-overlay.title = "Focus Monitor Up";
                };
                "Mod+Shift+L" = {
                  action = focus-monitor-right;
                  hotkey-overlay.title = "Focus Monitor Right";
                };
                "Mod+Shift+Left".action = focus-monitor-left;
                "Mod+Shift+Down".action = focus-monitor-down;
                "Mod+Shift+Up".action = focus-monitor-up;
                "Mod+Shift+Right".action = focus-monitor-right;

                # Move column to monitor
                "Mod+Shift+Ctrl+H" = {
                  action = move-column-to-monitor-left;
                  hotkey-overlay.title = "Move to Monitor Left";
                };
                "Mod+Shift+Ctrl+J" = {
                  action = move-column-to-monitor-down;
                  hotkey-overlay.title = "Move to Monitor Down";
                };
                "Mod+Shift+Ctrl+K" = {
                  action = move-column-to-monitor-up;
                  hotkey-overlay.title = "Move to Monitor Up";
                };
                "Mod+Shift+Ctrl+L" = {
                  action = move-column-to-monitor-right;
                  hotkey-overlay.title = "Move to Monitor Right";
                };
                "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
                "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
                "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
                "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;

                # Column management
                "Mod+BracketLeft".action = consume-or-expel-window-left;
                "Mod+BracketRight".action = consume-or-expel-window-right;
                "Mod+Comma".action = consume-window-into-column;
                "Mod+Period".action = expel-window-from-column;
                "Mod+C".action = center-column;
                "Mod+Ctrl+C".action = center-visible-columns;

                # Resize
                "Mod+R" = {
                  action = switch-preset-column-width;
                  hotkey-overlay.title = "Cycle Preset Widths";
                };
                "Mod+Shift+R" = {
                  action = switch-preset-window-height;
                  hotkey-overlay.title = "Cycle Preset Heights";
                };
                "Mod+Ctrl+R".action = reset-window-height;
                "Mod+F" = {
                  action = maximize-column;
                  hotkey-overlay.title = "Maximize Column";
                };
                "Mod+Shift+F".action = fullscreen-window;
                "Mod+M".action = maximize-window-to-edges;
                "Mod+Ctrl+F".action = expand-column-to-available-width;
                "Mod+Minus" = {
                  action = set-column-width "-10%";
                  hotkey-overlay.title = "Shrink Width";
                };
                "Mod+Equal" = {
                  action = set-column-width "+10%";
                  hotkey-overlay.title = "Grow Width";
                };
                "Mod+Shift+Minus" = {
                  action = set-window-height "-10%";
                  hotkey-overlay.title = "Shrink Height";
                };
                "Mod+Shift+Equal" = {
                  action = set-window-height "+10%";
                  hotkey-overlay.title = "Grow Height";
                };

                # Column display
                "Mod+W".action = toggle-column-tabbed-display;

                # Floating
                "Mod+V".action = toggle-window-floating;
                "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

                # Overview
                "Mod+O".action = toggle-overview;

                # Workspaces
                "Mod+1".action = focus-workspace 1;
                "Mod+2".action = focus-workspace 2;
                "Mod+3".action = focus-workspace 3;
                "Mod+4".action = focus-workspace 4;
                "Mod+5".action = focus-workspace 5;
                "Mod+6".action = focus-workspace 6;
                "Mod+7".action = focus-workspace 7;
                "Mod+8".action = focus-workspace 8;
                "Mod+9".action = focus-workspace 9;
                "Mod+Ctrl+1".action.move-column-to-workspace = 1;
                "Mod+Ctrl+2".action.move-column-to-workspace = 2;
                "Mod+Ctrl+3".action.move-column-to-workspace = 3;
                "Mod+Ctrl+4".action.move-column-to-workspace = 4;
                "Mod+Ctrl+5".action.move-column-to-workspace = 5;
                "Mod+Ctrl+6".action.move-column-to-workspace = 6;
                "Mod+Ctrl+7".action.move-column-to-workspace = 7;
                "Mod+Ctrl+8".action.move-column-to-workspace = 8;
                "Mod+Ctrl+9".action.move-column-to-workspace = 9;
                "Mod+Page_Down".action = focus-workspace-down;
                "Mod+Page_Up".action = focus-workspace-up;
                "Mod+U".action = focus-workspace-down;
                "Mod+I".action = focus-workspace-up;
                "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
                "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
                "Mod+Ctrl+U".action = move-column-to-workspace-down;
                "Mod+Ctrl+I".action = move-column-to-workspace-up;
                "Mod+Shift+Page_Down".action = move-workspace-down;
                "Mod+Shift+Page_Up".action = move-workspace-up;
                "Mod+Shift+U".action = move-workspace-down;
                "Mod+Shift+I".action = move-workspace-up;

                # Screenshot
                "Print".action.screenshot = { };
                "Ctrl+Print".action.screenshot-screen = { };
                "Alt+Print".action.screenshot-window = { };

                # Scroll
                "Mod+WheelScrollDown".action = focus-workspace-down;
                "Mod+WheelScrollDown".cooldown-ms = 150;
                "Mod+WheelScrollUp".action = focus-workspace-up;
                "Mod+WheelScrollUp".cooldown-ms = 150;
                "Mod+Ctrl+WheelScrollDown".action = move-column-to-workspace-down;
                "Mod+Ctrl+WheelScrollDown".cooldown-ms = 150;
                "Mod+Ctrl+WheelScrollUp".action = move-column-to-workspace-up;
                "Mod+Ctrl+WheelScrollUp".cooldown-ms = 150;
                "Mod+WheelScrollRight".action = focus-column-right;
                "Mod+WheelScrollLeft".action = focus-column-left;
                "Mod+Ctrl+WheelScrollRight".action = move-column-right;
                "Mod+Ctrl+WheelScrollLeft".action = move-column-left;
                "Mod+Shift+WheelScrollDown".action = focus-column-right;
                "Mod+Shift+WheelScrollUp".action = focus-column-left;
                "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
                "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

                # Media (allow-when-locked)
                "XF86AudioRaiseVolume" = {
                  action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+" "-l" "1.0";
                  allow-when-locked = true;
                };
                "XF86AudioLowerVolume" = {
                  action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-";
                  allow-when-locked = true;
                };
                "XF86AudioMute" = {
                  action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
                  allow-when-locked = true;
                };
                "XF86AudioMicMute" = {
                  action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
                  allow-when-locked = true;
                };
                "XF86AudioPlay" = {
                  action = spawn "playerctl" "play-pause";
                  allow-when-locked = true;
                };
                "XF86AudioStop" = {
                  action = spawn "playerctl" "stop";
                  allow-when-locked = true;
                };
                "XF86AudioPrev" = {
                  action = spawn "playerctl" "previous";
                  allow-when-locked = true;
                };
                "XF86AudioNext" = {
                  action = spawn "playerctl" "next";
                  allow-when-locked = true;
                };
                "XF86MonBrightnessUp" = {
                  action = spawn "brightnessctl" "--class=backlight" "set" "+5%";
                  allow-when-locked = true;
                };
                "XF86MonBrightnessDown" = {
                  action = spawn "brightnessctl" "--class=backlight" "set" "5%-";
                  allow-when-locked = true;
                };

                # Session
                "Mod+Shift+E".action = quit;
                "Ctrl+Alt+Delete".action = quit;
                "Mod+Shift+P".action = power-off-monitors;
                "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;
              };
            };
          }
        )
      ];
  };
}
