{
  config,
  lib,
  pkgs,
  ...
}:

let
  version = "1.3.17";

  opencodeDesktop = pkgs.stdenvNoCC.mkDerivation {
    pname = "opencode-desktop";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-desktop-linux-amd64.deb";
      sha256 = "sha256-M8ZYuwVDyLQ6XJYELoTTy6To/xaXYm1AXkrdbkjtPm8=";
    };

    nativeBuildInputs = with pkgs; [
      dpkg
      autoPatchelfHook
      wrapGAppsHook3
    ];

    buildInputs = with pkgs; [
      glib
      gtk3
      libsoup_3
      webkitgtk_4_1
    ];

    dontBuild = true;
    dontConfigure = true;
    dontStrip = true;

    preFixup = ''
      gappsWrapperArgs+=(
        --set GTK_THEME "adw-gtk3-dark"
      )
    '';

    unpackPhase = ''
      dpkg-deb -x "$src" .
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -r usr/* "$out"/
      chmod +x "$out/bin/OpenCode" "$out/bin/opencode-cli"

      runHook postInstall
    '';

    meta = with lib; {
      description = "OpenCode Desktop";
      homepage = "https://opencode.ai";
      license = licenses.mit;
      mainProgram = "OpenCode";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    };
  };
in
{
  options.opencode-desktop = {
    enable = lib.mkEnableOption "OpenCode Desktop";

    package = lib.mkOption {
      type = lib.types.package;
      default = opencodeDesktop;
      description = "The OpenCode Desktop package to install";
    };
  };

  config = lib.mkIf config.opencode-desktop.enable {
    nixos.environment.systemPackages = [ config.opencode-desktop.package ];
  };
}
