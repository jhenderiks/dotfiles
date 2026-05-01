{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.handy;
  xDisplay = ":99";
  handyPackage = inputs.handy.packages.${pkgs.stdenv.hostPlatform.system}.handy.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
        substituteInPlace src-tauri/src/clipboard.rs \
          --replace-fail \
            '    // Get the managed Enigo instance' \
            '    #[cfg(target_os = "linux")]
      if paste_method == PasteMethod::Direct {
          if try_direct_typing_linux(&text, settings.typing_tool)? {
              return Ok(());
          }
          info!("Falling back to enigo for direct text input");
       }

       // Get the managed Enigo instance'

      substituteInPlace src-tauri/src/settings.rs \
        --replace-fail \
          '        return KeyboardImplementation::Tauri;' \
          '        return KeyboardImplementation::HandyKeys;'
    '';
  });
  handy = pkgs.symlinkJoin {
    name = "handy-${handyPackage.version}";
    paths = [ handyPackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/handy \
        --set GTK_THEME Adwaita:dark \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1
    '';
  };
  handyStart = pkgs.writeShellScriptBin "handy-start" ''
    exec /run/wrappers/bin/sg input -c '${handy}/bin/handy --start-hidden'
  '';
in
{
  imports = [ inputs.handy.nixosModules.default ];

  options = {
    handy.enable = lib.mkEnableOption "Handy offline speech-to-text";
  };

  config = lib.mkIf cfg.enable {
    programs.handy = {
      enable = true;
      package = handy;
    };

    environment.systemPackages = [ pkgs.wtype ];

    users.users.${config.user.name}.extraGroups = [ "input" ];

    home-manager.sharedModules = [
      inputs.handy.homeManagerModules.default
      (
        { ... }:
        {
          dconf = {
            enable = true;
            settings."org/gnome/desktop/interface".color-scheme = lib.mkForce "prefer-dark";
          };

          services.handy = {
            enable = true;
            package = handy;
          };

          systemd.user.services.handy-xvfb = {
            Unit = {
              Description = "Headless X display for Handy";
              After = [ "niri.service" ];
              PartOf = [ "niri.service" ];
            };
            Service = {
              ExecStart = "${pkgs."xorg-server"}/bin/Xvfb ${xDisplay} -screen 0 1024x768x24 -nolisten tcp -ac";
              Restart = "on-failure";
              RestartSec = 2;
            };
            Install.WantedBy = [ "niri.service" ];
          };

          xdg.configFile."autostart/Handy.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=Handy
            Hidden=true
          '';

          systemd.user.services.handy = {
            Unit = {
              After = lib.mkForce [
                "niri.service"
                "handy-xvfb.service"
              ];
              PartOf = lib.mkForce [ "niri.service" ];
              Wants = [ "handy-xvfb.service" ];
            };
            Service = {
              Environment = [ "DISPLAY=${xDisplay}" ];
              ExecStart = lib.mkForce "${handyStart}/bin/handy-start";
            };
            Install.WantedBy = lib.mkForce [ "niri.service" ];
          };
        }
      )
    ];
  };
}
