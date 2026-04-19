{
  config,
  lib,
  pkgs,
  ...
}:

let
  version = "0.0.21-nightly.20260417.58";

  src = pkgs.fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/nightly-v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-HHH+M8NKBiTPOR7l5Z5EkaR7coj6I0/ajkKgujzkBjs=";
  };

  appimageContents = pkgs.appimageTools.extractType2 {
    pname = "t3code";
    inherit version src;
  };

  t3codePackage = pkgs.appimageTools.wrapType2 {
    pname = "t3code";
    inherit version src;

    extraPkgs = _: [ ];

    extraInstallCommands = ''
            mkdir -p $out/share/applications $out/share/pixmaps

            desktopFile="$(find ${appimageContents} -name '*.desktop' | head -n 1)"
      if [ -n "$desktopFile" ]; then
        install -m 444 -D "$desktopFile" $out/share/applications/t3code.desktop
        sed -i \
          -e 's|^Exec=.*|Exec=t3code %U|' \
          -e 's|^Icon=.*|Icon=t3code|' \
          $out/share/applications/t3code.desktop
      else
              cat > $out/share/applications/t3code.desktop <<'EOF'
      [Desktop Entry]
      Type=Application
      Name=T3 Code
      Exec=t3code %U
      Icon=t3code
      Categories=Development;
      Terminal=false
      EOF
            fi

            iconFile="$(find ${appimageContents} \( -iname '*.png' -o -iname '*.svg' \) | head -n 1)"
            if [ -n "$iconFile" ]; then
              iconExt="$(basename "$iconFile" | sed 's/^.*\.//')"
              install -m 444 -D "$iconFile" "$out/share/pixmaps/t3code.$iconExt"
            fi
    '';

    meta = {
      description = "Electron desktop app for T3 Code";
      homepage = "https://t3.codes";
      license = lib.licenses.mit;
      mainProgram = "t3code";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  };
in
{
  options.t3code = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = t3codePackage;
      description = "The T3 Code desktop app package to install.";
    };
  };

  config = lib.mkIf config.t3code.enable {
    nixos.environment.systemPackages = [ config.t3code.package ];
  };
}
