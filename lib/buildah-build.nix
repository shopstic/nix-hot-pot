{ dockerFile
, outputHash
, stdenv
, writeText
, writeScript
, runCommand
, docker-client
}:
let
  imagePlatform =
    if stdenv.isx86_64 then
      "linux/amd64" else
      "linux/arm64";
  script = writeScript "build" ''
    #!/usr/bin/env bash
    set -euo pipefail

    OUT_FILE=$(mktemp)
    IMAGE_ID=$(mktemp)

    buildah bud --platform=${imagePlatform} --jobs=0 --timestamp=0 --iidfile="$IMAGE_ID" /build 1>&2
    buildah push "$(cat "$IMAGE_ID")" docker-archive:"$OUT_FILE" 1>&2
    
    cat "$OUT_FILE"
  '';
  inputFiles = [ script dockerFile ];
  inputHash = builtins.foldl'
    (f1: f2: builtins.hashString "sha256" (builtins.concatStringsSep "" [ f1 f2 ]))
    ""
    (builtins.map (builtins.hashFile "sha256") inputFiles);
in
runCommand "buildah-${inputHash}"
{
  nativeBuildInputs = [ docker-client ];
  outputHashMode = "flat";
  outputHashAlgo = "sha256";
  outputHash = outputHash;
  meta = with stdenv.lib; {
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
  ''
    exec docker run \
        --rm \
        --init \
        --device /dev/fuse:rw \
        --security-opt seccomp=unconfined \
        --security-opt apparmor=unconfined \
        -v ${dockerFile}:/build/Dockerfile \
        -v ${script}:/build.sh \
        quay.io/buildah/stable:v1.23.1 \
        /build.sh > $out
  ''
