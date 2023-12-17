{ stdenv, jdk17, jdk17_headless, fetchurl }:
if stdenv.isDarwin then
  let
    dist = {
      aarch64-darwin = {
        arch = "aarch64";
        zuluVersion = "17.46.19";
        jdkVersion = "17.0.9";
        jdkSha256 = "sha256-1oN2duVbl3crZRLiU/2virKCuyFsD4NmtsWQXNArUFY=";
        jreSha256 = "sha256-BP4vlnFDkCwVgmKsxJkn8kIB8HIWMz+DjgnYerl8S20=";
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
      pname = "zulu${dist.zuluVersion}-ca-jre";
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
