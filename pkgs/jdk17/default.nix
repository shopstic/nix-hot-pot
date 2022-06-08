{ stdenv, jdk17, jdk17_headless, fetchurl }:
if stdenv.isDarwin then
  let
    dist = {
      x86_64-darwin = {
        arch = "x64";
        zuluVersion = "17.34.19";
        jdkVersion = "17.0.3";
        jdkSha256 = "sha256-qImyxVC2y2QhxuVZwamKPyo46+n+7ytIFXpYI0e6w2c=";
        jreSha256 = "sha256-QAjdLEYx2mwkK7kwf89VW6jNu1y37/qHFYcsxHApZak=";
      };
      aarch64-darwin = {
        arch = "aarch64";
        zuluVersion = "17.34.19";
        jdkVersion = "17.0.3";
        jdkSha256 = "sha256-eaRX8Qa/Mqr9JhpHSEcf0Q9c4qmqLMgWqRhkEEwAjf8=";
        jreSha256 = "sha256-SZzeHRh8/q5juii2USpL37P0VU0A2oal/qqsEoHpurI=";
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
