{ stdenv, jdk17, jdk17_headless, fetchurl }:
if stdenv.isDarwin then
  let
    dist = {
      x86_64-darwin = {
        arch = "x64";
        zuluVersion = "17.32.13";
        jdkVersion = "17.0.2";
        jdkSha256 = "sha256-idBLLZmwXcslEUF45l9qHFynQuElyrCmPYfn5C8/y4A=";
        jreSha256 = "sha256-W91VbAbioUG+MD7C8G5EF1iPvkygtI7iAUCbZmvGI0A=";
      };
      aarch64-darwin = {
        arch = "aarch64";
        zuluVersion = "17.32.13";
        jdkVersion = "17.0.2";
        jdkSha256 = "sha256-VCR93iSP+808BIZ1UEscUDuB2vLcDWSnnjU8SNODyXc=";
        jreSha256 = "sha256-TGOsKIyX4fnAVi6uq0Yrayr4RGBFeaZvVxZkta8ifjA=";
      };
    }."${stdenv.hostPlatform.system}";
  in
  {
    jdk = jdk17.overrideAttrs (oldAttrs: {
      pname = "zulu${dist.zuluVersion}-ca-jdk";
      version = dist.jdkVersion;
      src = fetchurl {
        url = "https://cdn.azul.com/zulu/bin/zulu${dist.zuluVersion}-ca-jdk${dist.jdkVersion}-macosx_${dist.arch}.tar.gz";
        sha256 = dist.jdkSha256;
        curlOpts = "-H Referer:https://www.azul.com/downloads/zulu/";
      };
    });
    jre = jdk17.overrideAttrs (oldAttrs: {
      pname = "zulu${dist.zuluVersion}-ca-jdk";
      version = dist.jdkVersion;
      src = fetchurl {
        url = "https://cdn.azul.com/zulu/bin/zulu${dist.zuluVersion}-ca-jre${dist.jdkVersion}-macosx_${dist.arch}.tar.gz";
        sha256 = dist.jreSha256;
        curlOpts = "-H Referer:https://www.azul.com/downloads/zulu/";
      };
      postFixup = "";
    });
  }
else
  {
    jdk = jdk17;
    jre = jdk17_headless;
  }
