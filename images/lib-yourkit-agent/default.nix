{ stdenv
, dockerTools
, fetchurl
, writeTextFile
}:
let
  version = "2022.3-b103";
  baseImage = dockerTools.pullImage {
    imageName = "public.ecr.aws/docker/library/alpine";
    imageDigest = "sha256:686d8c9dfa6f3ccfc8230bc3178d23f84eeaf7e457f36f271ab1acc53015037c";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-Cu5TDJS2tYQ3gilZWWjjpS12ZJ652UzR6Lza3SdSptI=" else
        "sha256-yJ1cLaQSzMU7s6vWFQJWTMFy72nT4DXFCA5cSTh94YU=";
    finalImageTag = "3.16.0";
    finalImageName = "alpine";
  };
  agentLib =
    if stdenv.isx86_64 then
      ./libs/amd64-libyjpagent.so else
      ./libs/arm64-libyjpagent.so;
  entrypoint = writeTextFile {
    name = "entrypoint";
    executable = true;
    text = ''
      #!/usr/bin/env sh
      cp ${agentLib} /target/libyjpagent.so
    '';
  };
in
dockerTools.buildImage {
  name = "lib-yourkit-agent";
  fromImage = baseImage;
  tag = version;
  config = {
    Entrypoint = [ entrypoint ];
  };
}

