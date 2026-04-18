{
  config,
  lib,
  pkgs,
  ...
}:

let
  version = "1.4.10";

  opencodeDesktop = pkgs.stdenvNoCC.mkDerivation {
    pname = "opencode-desktop";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-desktop-linux-amd64.deb";
      sha256 = "sha256-25XJw0VRNgauIWfZEk/IFrxf+r0QgP2F8RcAaUSAgBs=";
      curlOptsList = [
        "--http1.1"
        "--retry"
        "5"
        "--retry-delay"
        "2"
      ];
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
      stdenv.cc.cc.lib
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-good
      webkitgtk_4_1
    ];

    dontBuild = true;
    dontConfigure = true;
    dontStrip = true;

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}"
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${
          lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
            pkgs.gst_all_1.gstreamer
            pkgs.gst_all_1.gst-plugins-base
            pkgs.gst_all_1.gst-plugins-bad
            pkgs.gst_all_1.gst-plugins-good
          ]
        }"
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
