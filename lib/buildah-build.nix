{ name
, tag ? ""
, context
, buildArgs ? { }
, squash ? true
, outputHash
, stdenv
, lib
, writeScript
, runCommand
, docker-client
}:
let
  imagePlatform =
    if stdenv.isx86_64 then
      "linux/amd64" else
      "linux/arm64";
  buildArgsFlags = lib.mapAttrsToList (name: value: ''"--build-arg=${name}=${value}"'') buildArgs;
  flags = buildArgsFlags ++ lib.optional squash "--squash";
  script = writeScript "build" ''
    #!/usr/bin/env bash
    set -euo pipefail

    IMAGE_ID=$(mktemp)

    buildah bud \
      --platform=${imagePlatform} \
      --jobs=0 \
      --timestamp=0 \
      --tag=${tag} \
      --iidfile="$IMAGE_ID" \
      ${builtins.concatStringsSep " " flags} /context
    buildah push "$(cat "$IMAGE_ID")" docker-archive:"/out/archive"
    chown -R "$OUT_UID:$OUT_GID" /out
  '';

  command = ''
    OUT_DIR=$(mktemp -d)

    docker run \
        --rm \
        --init \
        --device /dev/fuse:rw \
        --security-opt seccomp=unconfined \
        --security-opt apparmor=unconfined \
        -v ${context}:/context \
        -v ${script}:/build.sh \
        -v $OUT_DIR:/out \
        -e OUT_UID="$(id -u)" \
        -e OUT_GID="$(id -g)" \
        docker.io/shopstic/buildah:v1.23.1@sha256:45247c6e60e775c8830719b5269144cebd0feffc5f24053972e76d4497ec133b \
        /build.sh

    mv $OUT_DIR/archive $out
    rm -Rf $OUT_DIR
  '';

  inputHash = builtins.hashString "sha256" command;
in
runCommand "image-${name}-${inputHash}"
{
  inherit outputHash;
  nativeBuildInputs = [ docker-client ];
  meta = with stdenv.lib; {
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
  outputHashMode = "flat";
  outputHashAlgo = "sha256";
}
  command
