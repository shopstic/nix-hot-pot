{ context
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

    OUT_FILE=$(mktemp)
    IMAGE_ID=$(mktemp)

    buildah bud \
      --platform=${imagePlatform} \
      --jobs=0 \
      --timestamp=0 \
      --iidfile="$IMAGE_ID" \
      ${builtins.concatStringsSep " " flags} /context 1>&2
    buildah push "$(cat "$IMAGE_ID")" docker-archive:"$OUT_FILE" 1>&2
    
    cat "$OUT_FILE"
  '';

  inputFiles = [ script context ];
  inputHash = builtins.foldl'
    (f1: f2: builtins.hashString "sha256" (builtins.concatStringsSep "" [ f1 f2 ]))
    ""
    inputFiles;
in
runCommand "buildah-build"
{
  nativeBuildInputs = [ docker-client ];
  meta = with stdenv.lib; {
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = outputHash;
}
  ''
    exec docker run \
        --rm \
        --init \
        --device /dev/fuse:rw \
        --security-opt seccomp=unconfined \
        --security-opt apparmor=unconfined \
        -v ${context}:/context \
        -v ${script}:/build.sh \
        quay.io/buildah/stable:v1.23.1 \
        /build.sh > $out
  ''