{ buildGo122Module
, fetchFromGitHub
, lib
}:
let
  pg-schema-diff = buildGo122Module rec {
    pname = "pg-schema-diff";
    version = "0.8.0";

    src = fetchFromGitHub {
      owner = "stripe";
      repo = "pg-schema-diff";
      rev = "v${version}";
      sha256 = "sha256-mwK5/+P5jhUakDaRD4RMLnRtEVUCR6H++A+FqVgPXbo=";
    };

    vendorHash = "sha256-VU1YY/AhEZYYGmSMLk9TI/ucugt/r1XhVoXp4szMEhA=";

    doCheck = false;

    meta = with lib; {
      description = "Go library for diffing Postgres schemas and generating SQL migrations";
      homepage = "https://github.com/stripe/pg-schema-diff";
      license = licenses.mit;
    };
  };
in
pg-schema-diff
