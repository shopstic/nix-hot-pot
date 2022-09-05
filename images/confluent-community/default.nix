{ lib
, stdenv
, writeTextFile
, buildEnv
, runCommand
, nix2container
, fetchzip
, dumb-init
}:
let
  name = "confluent-community";
  minorVersion = "7.2";
  version = "7.2.1";
  base-image = nix2container.pullImage
    {
      imageName = "docker.io/eclipse-temurin"; # 11.0.16_8-jdk
      imageDigest = "sha256:fd9eadffb87df27b63c1670d250eef5a86be1b3a05787ba4b11d0b2308c4b6fe";
      sha256 =
        if stdenv.isx86_64 then
          "sha256-gA4RCyivmlN971G3lG6YGQdaRfLGbxOFnx4xOJOMDqM=" else
          "sha256-BC8XswWSymocCfIXGnpwB/dFcmfRFTS6Xo7eSbyTzqc=";
    };

  confluent-community = fetchzip {
    url = "https://packages.confluent.io/archive/${minorVersion}/confluent-community-${version}.zip";
    sha256 = "sha256-y2wODaLRBmWpsG7NyEY3/DFzQGEvV56Mvh7OqaG1kZk=";
  };

  image = nix2container.buildImage
    {
      inherit name;
      fromImage = base-image;
      tag = version;
      maxLayers = 50;
      config = {
        env = [
          "PATH=${confluent-community}/bin:/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        ];
        entrypoint = [ "${dumb-init}/bin/dumb-init" "--" ];
      };
    };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
