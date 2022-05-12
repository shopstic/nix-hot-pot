{ lib
, stdenv
, buildahBuild
}:
let
  version = "1.23.3";
in
buildahBuild
{
  name = "buildah";
  context = ./context;
  tag = version;
  buildArgs = {
    fromTag = "v${version}";
    fromDigest = "sha256:b580c12dbeb2a6511a8c013f17cefdbf9d0ff9086a13196621219bc0ed3739cb";
  };
  outputHash =
    if stdenv.isx86_64 then
      "sha256-lm4eLt0Nb/D0KN/zWdXZWrDICfS5tBy+bjoa48CRz8w=" else
      "sha256-EchKK6dqbllzj2h3McEOwb/GY2xftKKx7uTYlWMmN7g=";
}

