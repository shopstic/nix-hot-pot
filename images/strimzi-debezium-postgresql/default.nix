{ stdenv
, buildahBuild
, dockerTools
}:
let
  name = "strimzi-debezium-postgresql";
  baseImage = buildahBuild
    {
      name = "${name}-base";
      context = ./context;
      buildArgs = {
        fromDigest = "sha256:f4d68bb94447c6612f70de7f6587e9e7ef712c83769ea1f11a8dbda0d241a059";
      };
      outputHash =
        if stdenv.isx86_64 then
          "sha256-3JqjNe+9n+oKxXad35q/szx+ttIgfyeFQQlh0nnh0YE=" else
          "sha256-XP2MV0XuFwAXa/six5lD+jizvptLu6LCTSuClB2DDrQ=";
    };
in
dockerTools.buildLayeredImage {
  name = name;
  fromImage = baseImage;
  tag = "0.27.1-kafka-2.8.0-debezium-1.9.0";
}
