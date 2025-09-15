{ rustPlatform
, fetchFromGitHub
, cacert
, rust-bin
, cargo
, rustc
, # Native compilation tools
  cmake
, gcc
, clang
, llvm
, lld
, # Protocol Buffers compiler
  protobuf
, # Python 3 for WPT tests
  python3
, # Additional system libraries
  pkg-config
, openssl
, zlib
, libffi
, glib
, stdenv
, lib
, libclang
}:
let
  rust-toolchain = rust-bin.stable."1.89.0".default.override {
    extensions = [ "rustfmt" "clippy" ];
  };

  buildDeps = [
    # Core build tools
    rust-toolchain
    cargo
    rustc

    # Native compilation tools
    cmake
    gcc
    clang
    llvm
    lld

    # Protocol Buffers compiler
    protobuf

    # Python 3 for WPT tests
    python3

    # Additional system libraries
    pkg-config
    openssl
    zlib
    libffi
  ] ++ (lib.optionals stdenv.isLinux [
    # Linux specific
    glib
  ]);
  src = fetchFromGitHub {
    owner = "nktpro";
    repo = "deno";
    rev = "feature/fix-otel";
    sha256 = "sha256-pjFHZK6NHYR93VsrDU5V7XO4wn+la4tBuyA/AA0bLd0=";
  };
in
rustPlatform.buildRustPackage {
  pname = "deno";
  version = "2.5.0";
  __noChroot = true;

  src = fetchFromGitHub {
    owner = "nktpro";
    repo = "deno";
    rev = "feature/fix-otel";
    sha256 = "sha256-pjFHZK6NHYR93VsrDU5V7XO4wn+la4tBuyA/AA0bLd0=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      # Git dependencies from https://github.com/nktpro/opentelemetry-rust?branch=feature%2Ffix-observable
      # All packages share the same git commit hash: 6357ef371697dc3eca8e36e8fc1478a3c8d6001b
      "opentelemetry-0.27.0" = "sha256-579+gB25eCZxAtf0TGdSQ9Hvetp9phgDZrGLjJD2XSA=";
      "opentelemetry-http-0.27.0" = "sha256-579+gB25eCZxAtf0TGdSQ9Hvetp9phgDZrGLjJD2XSA=";
      "opentelemetry-otlp-0.27.0" = "sha256-579+gB25eCZxAtf0TGdSQ9Hvetp9phgDZrGLjJD2XSA=";
      "opentelemetry-semantic-conventions-0.27.0" = "sha256-579+gB25eCZxAtf0TGdSQ9Hvetp9phgDZrGLjJD2XSA=";
      "opentelemetry_sdk-0.27.0" = "sha256-579+gB25eCZxAtf0TGdSQ9Hvetp9phgDZrGLjJD2XSA=";
    };
  };

  nativeBuildInputs = buildDeps ++ [ cacert ];

  buildInputs = [
    openssl
    zlib
    libffi
    libclang
  ] ++ (lib.optionals stdenv.isLinux [
    glib
  ]);

  # Build configuration
  cargoBuildFlags = [ "--bin" "deno" "--bin" "denort" ];

  # Skip tests that require network access or special setup
  doCheck = false;

  # Environment variables for the build
  CARGO_TARGET_DIR = "target";
  RUST_BACKTRACE = "1";

  # Ensure proper linking
  PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig:${zlib.dev}/lib/pkgconfig";

  # Platform-specific environment variables
  NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-L${lib.getLib openssl}/lib -L${lib.getLib zlib}/lib";
  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isLinux "-I${openssl.dev}/include -I${zlib.dev}/include";
  LIBCLANG_PATH = "${libclang.lib}/lib";
}
