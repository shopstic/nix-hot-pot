{ buildahBuild
, stdenv
}:
let
  from =
    let
      digest =
        if stdenv.isx86_64 then
          "sha256:5e604d3358ab7b6b734402ce2e19ddd822a354dc14843f34d36c603521dbb4f9" else
          "sha256:b4da1299e77c63f8706427cd39154e726a9b7646d29e2fc05d65b513373f9f5e";
    in
    builtins.trace digest "docker.io/library/alpine@${digest}";
in
buildahBuild {
  name = "test";
  context = ./.;
  buildArgs = {
    inherit from;
  };
  outputHash =
    if stdenv.isx86_64 then
      "sha256-ysTUcsLl9/aRwbGFSYrUkATwWFhv7zTA4zmd7GQ08V4=" else
      "sha256-lFffA+u/ImyDMHoweBdCy0R8DqtcpVKO1DJlFFA8zeM=";
}
