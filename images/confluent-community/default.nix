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
  minorVersion = "7.3";
  version = "7.3.2";
  base-image = nix2container.pullImage
    {
      imageName = "docker.io/eclipse-temurin"; # 17.0.6_10-jre-jammy
      imageDigest = "sha256:cef009d574f55e01a956f1b572552694573008d4b924bb32c8219971c2df8c59";
      sha256 =
        if stdenv.isx86_64 then
          "sha256-MBzDVutkYAR8Ekg2AAhssNqyR8LqFk/6aaOg+VlQWno=" else
          "sha256-v8jUyaKuFMm1VKIAebIoalv7GqRu0CyZYBCyEN51opE=";
    };

  confluent-community = fetchzip {
    url = "https://packages.confluent.io/archive/${minorVersion}/confluent-community-${version}.zip";
    sha256 = "sha256-Rhyob2HVOrVsjXpMod6cf800SzR4DBJJ2sDMibRyJOY=";
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
