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
  minorVersion = "7.5";
  version = "7.5.0";
  base-image = nix2container.pullImage
    {
      imageName = "docker.io/eclipse-temurin"; # 17.0.8_7-jre-jammy
      imageDigest = "sha256:6c78e6fb90509752eaf265b2b71df41199103332c86a38ddb06919108586fd7d";
      sha256 =
        if stdenv.isx86_64 then
          "sha256-qdKVOBZJrsQH4vwEGzTMiyTn+Z4LFpUzpraS8jj0Yp0=" else
          "sha256-EEEFFec3N5JX+f0EbL86ocYguYpquxLLsD4JTvjtk4U=";
    };

  confluent-community = fetchzip {
    url = "https://packages.confluent.io/archive/${minorVersion}/confluent-community-${version}.zip";
    sha256 = "sha256-nM9FN+Nllyae5imofLRjTJEQ+7z62zx+a62blAKNfB8=";
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
