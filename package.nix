{
  lib,
  rustPlatform,
  cargo-bundle,
  rcodesign,
  apple-sdk_15,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "notifykit";
  version = "0.1.1";

  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    cargo-bundle
  ]
  ++ lib.optionals stdenv.isDarwin [
    rcodesign
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    apple-sdk_15
  ];

  cargoBuildFlags = [
    "-p"
    "notifykit"
  ];

  postBuild = lib.optionalString stdenv.isDarwin ''
    cargo bundle --release -p notifykit
  '';

  installPhase = ''
    runHook preInstall
  ''
  + (
    if stdenv.isDarwin then
      ''
        mkdir -p $out/Applications
        cp -r target/release/bundle/osx/NotifyKit.app $out/Applications/
        mkdir -p $out/bin
        ln -s $out/Applications/NotifyKit.app/Contents/MacOS/notifykit $out/bin/notifykit
      ''
    else
      ''
        mkdir -p $out/bin
        cp target/release/notifykit $out/bin/
      ''
  )
  + ''
    runHook postInstall
  '';

  # Sign after fixup (stripping would invalidate signature if done earlier)
  postFixup = lib.optionalString stdenv.isDarwin ''
    ${rcodesign}/bin/rcodesign sign $out/Applications/NotifyKit.app
  '';

  meta = with lib; {
    description = "macOS notification CLI with Claude Code hook support";
    homepage = "https://github.com/macalinao/notifykit";
    license = licenses.asl20;
    platforms = platforms.darwin;
    mainProgram = "notifykit";
  };
}
