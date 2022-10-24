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
  version = "7.2.2";
  base-image = nix2container.pullImage
    {
      imageName = "docker.io/eclipse-temurin"; # 11.0.16.1_1-jdk-focal
      imageDigest = "sha256:8d77cbc386f4c1c84b3cf11d8265e1e86524806e487e24d176ccd7ef55769323";
      sha256 =
        if stdenv.isx86_64 then
          "sha256-3fD89QIofM94Q3nP8D2LjNQqJ/vVvVfeToPbBKzWtO0=" else
          "sha256-PVBwkTpsLzT5gPaNeFh+PfffWR93Ry6RgZy4zaQ951I=";
    };

  confluent-community = fetchzip {
    url = "https://packages.confluent.io/archive/${minorVersion}/confluent-community-${version}.zip";
    sha256 = "sha256-PVBwkTpsLzT5gPaNeFh+PfffWR93Ry6RgZy4zaQ951I=";
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
