{ pkgs, lib, config, ... }:
{
  languages.rust = {
    enable = true;
    toolchainFile = ./rust-toolchain.toml;
  };

  packages = [
    pkgs.protobuf
  ];

  services.lnd = {
    enable = true;
    restPort = 7080;
  };

  services.nostr-rs-relay = {
    enable = true;
  };

  env.MOSTRO_SETTINGS_DIR = "${config.devenv.state}/mostro";

  enterShell = ''
    mkdir -p "$MOSTRO_SETTINGS_DIR"
    if [ ! -f "$MOSTRO_SETTINGS_DIR/settings.toml" ]; then
      ${pkgs.gnused}/bin/sed \
        -e "s|lnd_cert_file = .*|lnd_cert_file = '$LND_CERT_FILE'|" \
        -e "s|lnd_macaroon_file = .*|lnd_macaroon_file = '$LND_MACAROON_FILE'|" \
        -e "s|lnd_grpc_host = .*|lnd_grpc_host = '$LND_GRPC_HOST'|" \
        settings.tpl.toml > "$MOSTRO_SETTINGS_DIR/settings.toml"
      echo "Generated mostro settings at $MOSTRO_SETTINGS_DIR/settings.toml"
      echo "Run mostrod with: cargo run -- -d $MOSTRO_SETTINGS_DIR"
    fi
  '';

  git-hooks.tools = {
    cargo = lib.mkForce config.languages.rust.toolchainPackage;
    clippy = lib.mkForce config.languages.rust.toolchainPackage;
    rustfmt = lib.mkForce config.languages.rust.toolchainPackage;
  };

  git-hooks.hooks = {
    clippy.enable = true;
    rustfmt.enable = true;
  };

  enterTest = ''
    cargo clippy --all-targets --all-features -- -D warnings
  '';
}
