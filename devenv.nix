{
  pkgs,
  ...
}:

{
  packages = with pkgs; [
    git
    nixfmt-rfc-style

    rustup
    cargo-bundle
    cargo-expand
    cargo-nextest

    imagemagick # for generating iconset from SVG
  ];

  pre-commit.hooks = {
    nixfmt-rfc-style.enable = true;
    rustfmt.enable = true;
    prettier = {
      enable = true;
      excludes = [
        "flake.lock"
        "Cargo.lock"
      ];
    };
  };
}
