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

  cargoSha256 = "sha256-vFh22L/gXZkS2k7s6Qp7TbenUMypBplBCC6R2g3Lvl4=";

  buildInputs = lib.optional stdenv.isDarwin pkgs.darwin.Security;

  meta = with lib; {
    description = "AWS Credentials manager via Okta";
    homepage = "https://github.com/jonathanmorley/oktaws";
    license = licenses.asl20;
  };
}