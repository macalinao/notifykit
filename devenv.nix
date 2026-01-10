{
  pkgs,
  ...
}:

{
  packages = with pkgs; [
    git
    nixfmt-rfc-style

    rustup
    cargo-expand
    cargo-nextest
  ];
}
