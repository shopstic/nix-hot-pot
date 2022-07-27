{ stdenv
, lib
, buildahBuild
, dockerTools
, awscli2
, jq
}:
let
  name = "aws-cli2-jq";
  baseImage = dockerTools.pullImage {
    imageName = "docker.io/library/ubuntu";
    imageDigest = "sha256:b6b83d3c331794420340093eb706a6f152d9c1fa51b262d9bf34594887c2c7ac";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-puR757IYOrsuM3us+5QVvZodq19v/3Zzsu8B0YO+6Nk=" else
        "sha256-yPysq07M5xXM/WiLxxY4X4gVCtfRE/DEp/OblhH9Ngk=";
  };

  binPath = lib.makeBinPath [
    awscli2
    jq
  ];
in
dockerTools.buildLayeredImage
{
  inherit name;
  fromImage = baseImage;
  tag = awscli2.version;
  config = {
    Env = [
      "PATH=${binPath}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ];
  };
}
