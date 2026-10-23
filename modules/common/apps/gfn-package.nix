{
  lib,
  runCommand,
  ostree,
  cacert,
  buildFHSEnv,
  writeShellScript,
}:

let
  version = "2.0.88.129";
  commit = "a6efb6892f34313ec6bf4dee6716a5b25c3e2215090395d5de89cb0735a72fd0";

  # NVIDIA distributes the native client only through its OSTree/Flatpak repository.
  src =
    runCommand "gfn-source"
      {
        nativeBuildInputs = [ ostree ];
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = "sha256-G6lDjrpr1bJ7/EOzCp0y9leEdU5P+HSp855NmXIFHp4=";
      }
      ''
        ostree --repo=repo init --mode=archive
        ostree --repo=repo remote add --no-gpg-verify \
          --set=tls-ca-path="$SSL_CERT_FILE" nvidia \
          https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow_repo
        ostree --repo=repo pull nvidia ${commit}
        ostree --repo=repo checkout --user-mode ${commit} "$out"
      '';

  app = runCommand "gfn-${version}-app" { } ''
    cp -r ${src}/files "$out"
    chmod -R u+w "$out"
    # Updates belong to Nix, not NVIDIA's Flatpak updater.
    substituteInPlace "$out/cef/Resources/GeForceNOW.json" \
      --replace-fail 'nv-startup-autoupdate=true' 'nv-startup-autoupdate=false'
  '';
in
buildFHSEnv {
  pname = "gfn";
  inherit version;

  targetPkgs =
    pkgs: with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      curl
      dbus
      expat
      fontconfig
      glib
      gtk3
      libdrm
      libgbm
      libglvnd
      libva
      libvdpau
      libX11
      libxcb
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXScrnSaver
      libXtst
      libxkbcommon
      mesa
      nspr
      nss
      openssl
      pango
      pipewire
      pulseaudio
      stdenv.cc.cc.lib
      systemd
      vulkan-loader
      wayland
      xdg-utils
      xrandr
      zlib
      # NVIDIA opens login URLs and queries the host through flatpak-spawn.
      (writeShellScriptBin "flatpak-spawn" ''
        if [ "''${1:-}" != "--host" ]; then
          exit 2
        fi
        shift
        export PATH="/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin"
        exec ${systemd}/bin/systemd-run --user --quiet --wait --pipe --collect -- ${coreutils}/bin/env "$@"
      '')
    ];

  # Preserve the /app path expected by the proprietary binaries.
  extraBwrapArgs = [ "--ro-bind ${app} /app" ];
  runScript = writeShellScript "gfn-launch" ''
    # The client uses /app for assets only when it detects its Flatpak app ID.
    export FLATPAK_ID=com.nvidia.geforcenow
    export SDL_VIDEODRIVER=x11
    export LD_LIBRARY_PATH="/app/cef:/app/cef/dependencies:/app/nvc:/app/nvtelemetry:''${LD_LIBRARY_PATH:-}"
    cd /app/cef
    exec ./GeForceNOW "$@"
  '';

  extraInstallCommands = ''
    mkdir -p "$out/share"
    cp -r ${app}/share/applications ${app}/share/icons "$out/share/"
    substituteInPlace "$out/share/applications/com.nvidia.geforcenow.desktop" \
      --replace-fail 'Exec=GeForceNOW' "Exec=$out/bin/gfn %U"
    printf '\nMimeType=x-scheme-handler/geforcenow;\n' >> "$out/share/applications/com.nvidia.geforcenow.desktop"
  '';

  passthru = { inherit src commit; };
  meta = {
    description = "Official NVIDIA GeForce NOW cloud gaming client";
    homepage = "https://www.nvidia.com/en-us/geforce-now/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "gfn";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
