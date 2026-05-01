{
  config,
  lib,
  pkgs,
  ...
}:

let
  opencode = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "opencode";
    version = "1.14.25";

    src = pkgs.fetchFromGitHub {
      owner = "anomalyco";
      repo = "opencode";
      tag = "v${finalAttrs.version}";
      hash = "sha256-v1aaq4HWAJ5wZm9bUeaRkyKr0iYjdOhigr/I31wwhEk=";
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
      outputHash = "sha256-NQWd6GhidirjQvFUzBWdaNjY5prSmkTX1VkrRYISqK4=";
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

  };

  config = lib.mkIf config.opencode.enable {
    environment.systemPackages = [ config.opencode.package ];
  };
}
