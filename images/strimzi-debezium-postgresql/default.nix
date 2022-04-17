{ stdenv
, buildahBuild
, dockerTools
}:
let
  name = "strimzi-debezium-postgresql";
  tag = "0.27.1-kafka-2.8.0-debezium-1.9.0";
in
buildahBuild
{
  name = name;
  tag = "${name}:${tag}";
  context = ./context;
  buildArgs = {
    fromDigest = "sha256:f4d68bb94447c6612f70de7f6587e9e7ef712c83769ea1f11a8dbda0d241a059";
  };
  outputHash =
    if stdenv.isx86_64 then
      "sha256-AqJqVRW8cyRUwfFoablsCU58IugCRmmUEkeJ9Jj0Erk=" else
      "sha256-vzYvEFeNOU8+KPHmj7vKmN/Pd+jwlluzWIW743lW4rM=";
}