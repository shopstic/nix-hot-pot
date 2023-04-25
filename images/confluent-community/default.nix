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
  version = "7.3.3";
  base-image = nix2container.pullImage
    {
      imageName = "docker.io/eclipse-temurin"; # 17.0.6_10-jre-jammy
      imageDigest = "sha256:3ca86c6a49d66e14d634d4b93ea5a5e195996843c60324c8bfeaaf6769985ccb";
      sha256 =
        if stdenv.isx86_64 then
          "sha256-6iEtCR0AOuWWP86jT7xkmFoRLCwQ7HMd/Vk0W4ty15g=" else
          "sha256-f6CQfPKcEq477Fp8j57GtvDYeURDJfnpfg7ii95YoW8=";
    };

  confluent-community = fetchzip {
    url = "https://packages.confluent.io/archive/${minorVersion}/confluent-community-${version}.zip";
    sha256 = "sha256-jNhw83VVfHb/RnjxvAObIVsf+OlWPrXfJVoHxPihyH0=";
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
