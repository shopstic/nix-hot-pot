{ stdenv, jdk17, fetchurl }:
if stdenv.isDarwin then
  let
    dist = {
      x86_64-darwin = {
        arch = "x64";
        zuluVersion = "17.32.13";
        jdkVersion = "17.0.2";
        sha256 = "sha256-idBLLZmwXcslEUF45l9qHFynQuElyrCmPYfn5C8/y4A=";
      };
      aarch64-darwin = {
        arch = "aarch64";
        zuluVersion = "17.32.13";
        jdkVersion = "17.0.2";
        sha256 = "sha256-VCR93iSP+808BIZ1UEscUDuB2vLcDWSnnjU8SNODyXc=";
      };
    }."${stdenv.hostPlatform.system}";
  in
  jdk17.overrideAttrs (oldAttrs: {
    pname = "zulu${dist.zuluVersion}-ca-jdk";
    version = dist.jdkVersion;
    src = fetchurl {
      url = "https://cdn.azul.com/zulu/bin/zulu${dist.zuluVersion}-ca-jdk${dist.jdkVersion}-macosx_${dist.arch}.tar.gz";
      inherit (dist) sha256;
      curlOpts = "-H Referer:https://www.azul.com/downloads/zulu/";
    };
  })
else
  jdk17
