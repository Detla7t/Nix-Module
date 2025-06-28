{ stdenv, lib, pkgs, pkg-config, pipewire, libgcc }:

stdenv.mkDerivation rec {
  pname = "midi-mixer-example";
  version = "0.1";

  src = ./.;

  # We need pkg-config (to get the correct compile flags) and the pipewire library.
  nativeBuildInputs = [ 
  	libgcc
  	pkg-config 
  	pipewire
  ];
  buildInputs = [
  	pipewire 
  ];

  buildPhase = ''
    NIX_CFLAGS_COMPILE="$(pkg-config --cflags --libs libpipewire-0.3) $NIX_CFLAGS_COMPILE"
    echo "Compiling midi_mixer.c..."
    gcc -o midi_mixer midi_mixer.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp midi_mixer $out/bin/
  '';

  meta = with lib; {
    description = "Example MIDI mixer app using PipeWire API";
    license = licenses.mit;
    #platforms = [ "linux" ];
    maintainers = with maintainers; [ yourName ];
  };
}

