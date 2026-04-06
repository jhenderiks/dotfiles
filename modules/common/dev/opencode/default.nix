{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Pinned version and hashes
  # To update: run ./scripts/update-opencode.sh
  version = "1.3.17";

  # Base URL for the release
  baseUrl = "https://github.com/anomalyco/opencode/releases/download/v${version}";

  # Platform-specific sources
  sources = {
    x86_64-linux = {
      url = "${baseUrl}/opencode-linux-x64.tar.gz";
      sha256 = "sha256-GeVAhAz9BK/r7ZLP5n3ODNbEJe1fcp75RugHH3diBak="; # v1.3.17
    };
    aarch64-linux = {
      url = "${baseUrl}/opencode-linux-arm64.tar.gz";
      sha256 = "sha256-NFKT7SnHA888Sw5pbbUMNYbJc6TU/5Dx21tsu7ss7ks="; # v1.3.17
    };
    x86_64-darwin = {
      url = "${baseUrl}/opencode-darwin-x64.zip";
      sha256 = "sha256-VUthAQJsZAxOX21PT3c42LKEAVXsp1uTrAutnVx1bA8="; # v1.3.17
    };
    aarch64-darwin = {
      url = "${baseUrl}/opencode-darwin-arm64.zip";
      sha256 = "sha256-FEvtkU6MwAS6T3n9AdYfGtEhpkF+E++X3G/oZlyJA7s="; # v1.3.17
    };
  };

  # Current platform source
  currentSource =
    sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "opencode: unsupported platform ${pkgs.stdenv.hostPlatform.system}");

  # Is this a zip file? (Darwin builds)
  isZip = lib.hasSuffix ".zip" currentSource.url;

  # Package derivation
  # Note: dontStrip = true is required because opencode is a Bun-compiled binary
  # that embeds JavaScript/resources in the ELF file. Stripping corrupts these
  # embedded resources, leaving only the base Bun runtime.
  opencode = pkgs.stdenv.mkDerivation rec {
    pname = "opencode";
    inherit version;

    src = pkgs.fetchurl {
      url = currentSource.url;
      sha256 = currentSource.sha256;
    };

    nativeBuildInputs = lib.optionals isZip [ pkgs.unzip ];

    dontBuild = true;
    dontConfigure = true;
    # CRITICAL: Bun-compiled binaries break when stripped
    dontStrip = true;

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp opencode $out/bin/

      # Make it executable
      chmod +x $out/bin/opencode

      # Optional: add shell completions if they exist in the tarball
      if [ -d "completions" ]; then
        mkdir -p $out/share/opencode/completions
        cp -r completions/* $out/share/opencode/completions/
      fi

      runHook postInstall
    '';

    meta = with lib; {
      description = "Open source AI coding agent";
      homepage = "https://opencode.ai";
      license = licenses.mit;
      maintainers = [ ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    };
  };
in
{
  imports = [
    ./updater.nix
  ];

  options.opencode = {
    enable = lib.mkEnableOption "opencode AI coding agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = opencode;
      description = "The opencode package to install";
    };
  };

  config = lib.mkIf config.opencode.enable {
    environment.systemPackages = [ config.opencode.package ];
  };
}
