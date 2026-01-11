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
}
