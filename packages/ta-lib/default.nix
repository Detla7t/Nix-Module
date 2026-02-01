{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "ta-lib";
  version = "0.6.4";
  src = fetchFromGitHub {
    owner = "TA-Lib";
    repo = "ta-lib";
    rev = "main";
    sha256 = "sha256-zs9IgMrjRsf+piA1mnfL0dQrMpM3ISO8UDmp01Ka86U=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];
  hardeningDisable = [ "format" ];
  
}