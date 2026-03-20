{ pkgs, ... }:
{
  languages.rust = {
    enable = true;
    toolchainFile = ./rust-toolchain.toml;
  };

  packages = [
    pkgs.protobuf
    pkgs.htop
  ];

  pre-commit.hooks = {
    clippy.enable = true;
    rustfmt.enable = true;
  };

  enterTest = ''
    cargo clippy --all-targets --all-features -- -D warnings
  '';
}
