{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  cfg = config.stt;

  niriAvailable = lib.hasAttrByPath [ "niri" "enable" ] options;
  niriEnabled = niriAvailable && config.niri.enable;

  baseEnModel = pkgs.fetchurl {
    name = "ggml-base.en.bin";
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
    hash = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
  };

  sttToggle = pkgs.writeShellApplication {
    name = "stt-toggle";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      gnused
      libnotify
      pipewire
      procps
      whisper-cpp
      wtype
    ];

    text = ''
      state_dir="''${XDG_RUNTIME_DIR:-/tmp}/stt"
      pid_file="$state_dir/record.pid"
      audio_file="$state_dir/dictation.wav"
      log_file="$state_dir/stt.log"

      notify() {
        notify-send --app-name="STT" "Dictation" "$1" --expire-time=1200 >/dev/null 2>&1 || true
      }

      mkdir -p "$state_dir"

      if [ -f "$pid_file" ]; then
        recorder_pid="$(cat "$pid_file")"
        if kill -0 "$recorder_pid" >/dev/null 2>&1; then
          kill -INT "$recorder_pid"
          for _ in $(seq 1 50); do
            if ! kill -0 "$recorder_pid" >/dev/null 2>&1; then
              break
            fi
            sleep 0.1
          done
        fi
        rm -f "$pid_file"

        audio_size="$(wc -c < "$audio_file" 2>/dev/null || printf 0)"
        if [ "$audio_size" -lt 4096 ]; then
          notify "No audio captured; mic may be asleep"
          exit 1
        fi

        notify "Transcribing..."
        text="$(whisper-cli \
          --model ${baseEnModel} \
          --file "$audio_file" \
          --language en \
          --threads ${toString cfg.local.threads} \
          --no-timestamps \
          --no-prints \
          2>"$log_file")"
        text="$(printf '%s' "$text" | sed -e ':a' -e 'N' -e '$!ba' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

        if [ -z "$text" ]; then
          notify "No speech detected; check $state_dir"
          exit 1
        fi

        printf '%s' "$text" | wtype -
        rm -f "$audio_file"
        notify "Inserted transcription"
        exit 0
      fi

      rm -f "$audio_file" "$log_file"
      nohup pw-record --verbose --rate 16000 --channels 1 "$audio_file" >"$log_file" 2>&1 &
      recorder_pid="$!"
      printf '%s\n' "$recorder_pid" >"$pid_file"

      for _ in $(seq 1 40); do
        if sed -n 's/.*ticks:\([1-9][0-9]*\).*/\1/p' "$log_file" 2>/dev/null | grep -q .; then
          notify "Recording..."
          exit 0
        fi

        if ! kill -0 "$recorder_pid" >/dev/null 2>&1; then
          rm -f "$pid_file"
          notify "Recording failed"
          exit 1
        fi

        sleep 0.05
      done

      kill -INT "$recorder_pid" >/dev/null 2>&1 || true
      rm -f "$pid_file"
      notify "Mic not ready"
      exit 1
    '';
  };
in
{
  options = with lib; {
    stt = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      hotkey = mkOption {
        type = types.str;
        default = "Mod+S";
      };

      local = {
        model = mkOption {
          type = types.enum [ "base.en" ];
          default = "base.en";
        };

        threads = mkOption {
          type = types.ints.positive;
          default = 8;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ sttToggle ];

    assertions = [
      {
        assertion = cfg.local.model == "base.en";
        message = "Only stt.local.model = \"base.en\" is currently packaged.";
      }
    ];

    home-manager.sharedModules = lib.mkIf niriEnabled [
      (
        { config, ... }:
        {
          programs.niri.settings.binds.${cfg.hotkey}.action = config.lib.niri.actions.spawn "stt-toggle";
        }
      )
    ];
  };
}
