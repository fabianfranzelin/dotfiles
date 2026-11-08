{ pkgs }:

# Keep the Nix Bazel cache separate and use the trust store built by .envrc.
pkgs.writeShellScriptBin "bazel" ''
  startup=(
    "--output_user_root=$HOME/.cache/bazel-nix"
    "--bazelrc=${./nix.bazelrc}"
  )
  if [ -n "''${BAZEL_NIX_TRUSTSTORE:-}" ] && [ -f "$BAZEL_NIX_TRUSTSTORE" ]; then
    startup+=(
      "--host_jvm_args=-Djavax.net.ssl.trustStore=$BAZEL_NIX_TRUSTSTORE"
      "--host_jvm_args=-Djavax.net.ssl.trustStorePassword=changeit"
      "--host_jvm_args=-Djavax.net.ssl.trustStoreType=PKCS12"
    )
  fi
  exec ${pkgs.bazel_9}/bin/bazel "''${startup[@]}" "$@"
''
