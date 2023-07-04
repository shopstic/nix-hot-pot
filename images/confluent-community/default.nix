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
  minorVersion = "7.4";
  version = "7.4.0";
  base-image = nix2container.pullImage
    {
      imageName = "docker.io/eclipse-temurin"; # 17.0.7_7-jre-jammy
      imageDigest = "sha256:ec3db222e166ce99c524dfb2b5c9604b889c59756b50a324180c4e0c457579cf";
      sha256 =
        if stdenv.isx86_64 then
          "sha256-7KZjEhOLYqUPYOXGpkIUm0IbcIzO1CMhl3IbwTpPpVM=" else
          "sha256-FmNwcRYr3C37zt+juc5VyIMLmVFblOlQYXzMunLynOg=";
    };

  confluent-community = fetchzip {
    url = "https://packages.confluent.io/archive/${minorVersion}/confluent-community-${version}.zip";
    sha256 = "sha256-sp4X2h1NZoiEI9mh8sHjyM8Vrbe6tIanB8NYy6HCJ30=";
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
