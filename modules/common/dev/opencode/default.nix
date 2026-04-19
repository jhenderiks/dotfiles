{
  config,
  lib,
  pkgs,
  ...
}:

let
  user = config.user.name;
  home = config.users.users.${user}.home;
  serverConfig = {
    "$schema" = "https://opencode.ai/config.json";
    server = {
      inherit (config.opencode.server)
        cors
        hostname
        mdns
        mdnsDomain
        port
        ;
    };
  };

  opencode = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "opencode";
    version = "1.14.18";

    src = pkgs.fetchFromGitHub {
      owner = "anomalyco";
      repo = "opencode";
      tag = "v${finalAttrs.version}";
      hash = "sha256-wEjksPEPzEe2BCySqjorMXrbnBWNCp+YAaCiZWV2ZIc=";
    };

    node_modules = pkgs.stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-node_modules";
      inherit (finalAttrs) version src;

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

      nativeBuildInputs = [
        pkgs.bun
        pkgs.writableTmpDirAsHomeHook
      ];

      dontConfigure = true;

      buildPhase = ''
        runHook preBuild

        bun install \
          --cpu="*" \
          --ignore-scripts \
          --no-progress \
          --os="*"

        bun --bun ./nix/scripts/canonicalize-node-modules.ts
        bun --bun ./nix/scripts/normalize-bun-binaries.ts

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        find . -type d -name node_modules -exec cp -R --parents {} $out \;

        runHook postInstall
      '';

      dontFixup = true;
      outputHash = "sha256-nj088y5+Ja+Lc2Em4s4ZSoS2/lkWC41smVYlynXas9E=";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

    nativeBuildInputs = [
      pkgs.bun
      pkgs.nodejs
      pkgs.installShellFiles
      pkgs.makeBinaryWrapper
      pkgs.models-dev
      pkgs.writableTmpDirAsHomeHook
    ];

    postPatch = ''
      substituteInPlace packages/script/src/index.ts \
        --replace-fail 'throw new Error(`This script requires bun@''${expectedBunVersionRange}' \
                       'console.warn(`Warning: This script requires bun@''${expectedBunVersionRange}'
    '';

    configurePhase = ''
      runHook preConfigure

      cp -R ${finalAttrs.node_modules}/. .
      patchShebangs node_modules
      patchShebangs packages/*/node_modules

      runHook postConfigure
    '';

    env.MODELS_DEV_API_JSON = "${pkgs.models-dev}/dist/_api.json";
    env.OPENCODE_VERSION = finalAttrs.version;
    env.OPENCODE_CHANNEL = "stable";

    buildPhase = ''
      runHook preBuild

      cd ./packages/opencode
      bun --bun ./script/build.ts --single --skip-install
      bun --bun ./script/schema.ts schema.json

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm755 dist/opencode-*/bin/opencode $out/bin/opencode
      wrapProgram $out/bin/opencode \
       --prefix PATH : ${
         lib.makeBinPath (
           [ pkgs.ripgrep ] ++ lib.optionals pkgs.stdenvNoCC.hostPlatform.isDarwin [ pkgs.sysctl ]
         )
       }

      install -Dm644 schema.json $out/share/opencode/schema.json

      runHook postInstall
    '';

    postInstall = lib.optionalString (pkgs.stdenvNoCC.buildPlatform.canExecute pkgs.stdenvNoCC.hostPlatform) ''
      installShellCompletion --cmd opencode \
        --bash <($out/bin/opencode completion) \
        --zsh <(SHELL=/bin/zsh $out/bin/opencode completion)
    '';

    nativeInstallCheckInputs = [
      pkgs.versionCheckHook
      pkgs.writableTmpDirAsHomeHook
    ];
    doInstallCheck = true;
    versionCheckKeepEnvironment = [ "HOME" ];
    versionCheckProgramArg = "--version";

    passthru = {
      jsonschema = "${placeholder "out"}/share/opencode/schema.json";
      updateScript = pkgs.nix-update-script {
        extraArgs = [
          "--subpackage"
          "node_modules"
        ];
      };
    };

    meta = {
      description = "AI coding agent built for the terminal";
      homepage = "https://github.com/anomalyco/opencode";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [
        delafthi
        DuskyElf
        graham33
        superherointj
      ];
      sourceProvenance = with lib.sourceTypes; [ fromSource ];
      platforms = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      mainProgram = "opencode";
      badPlatforms = [ "x86_64-darwin" ];
    };
  });
in
{

  options.opencode = {
    enable = lib.mkEnableOption "opencode AI coding agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = opencode;
      description = "The opencode package to install. Defaults to the repo-pinned source build so it can track newer releases than nixpkgs without using release asset tarballs.";
    };

    server = {
      enable = lib.mkEnableOption "OpenCode web server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 4096;
        description = "Port for the OpenCode web server.";
      };

      hostname = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Hostname for the OpenCode web server to bind to.";
      };

      mdns = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable mDNS discovery for the OpenCode web server.";
      };

      mdnsDomain = lib.mkOption {
        type = lib.types.str;
        default = "opencode.local";
        description = "mDNS domain name advertised by the OpenCode web server.";
      };

      cors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional allowed CORS origins for the OpenCode web server.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.opencode.enable {
      environment.systemPackages = [ config.opencode.package ];
    })

    (lib.mkIf config.opencode.server.enable {
      opencode.enable = true;

      home-manager.users.${user}.home.file.".config/opencode/opencode.json".text = builtins.toJSON serverConfig;

      nixos.systemd.user.services.opencode-web = {
        description = "OpenCode web server";
        wantedBy = [ "default.target" ];

        serviceConfig = {
          ExecStart = "${lib.getExe config.opencode.package} web";
          Environment = [ "BROWSER=${pkgs.coreutils}/bin/true" ];
          Restart = "on-failure";
          RestartSec = "5s";
          WorkingDirectory = home;
        };
      };
    })
  ];
}
