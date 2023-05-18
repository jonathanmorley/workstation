{ pkgs, lib, stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "oktaws";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "jonathanmorley";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Avo43iP5IDDStR1lEaE4DcGZlQHUu6PiPx0Udi3iqT8=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "tracing-tree-0.2.0" = "sha256-/JNeAKjAXmKPh0et8958yS7joORDbid9dhFB0VUAhZc=";
    };
  };

  buildInputs = lib.optional stdenv.isDarwin pkgs.darwin.Security;

  meta = with lib; {
    description = "AWS Credentials manager via Okta";
    homepage = "https://github.com/jonathanmorley/oktaws";
    license = licenses.asl20;
  };
}