{ stdenv, pkgs, fetchurl, lib, pkg-config }:
stdenv.mkDerivation rec {
    pname = "wallpaper_pack";
    version = "0.0.5";

    current_folder = builtins.toString ./.;

    share_archive = builtins.fetchurl {#fetchTarball {#
        url = "file://${current_folder}/share.tar.gz";
        #sha256 = lib.fakeSha256;
        sha256 = "08la6l6k9dbdyxivz71k05bj93xsmqqbdrds4h3wwdd1v67hgf8x";
    };

    #dontUnpack = true;
    dontBuild = true;
    dontInstall = true;
    #dontPatchShebangs = true;   # Reduces build time for this package by approximately 1 seconds
    #dontFixup = true;   # Skips long fixup phase that take ~13 seconds alone. due to it checking every file and there being alot of files

    unpackPhase = ''
        mkdir -p $out
        tar -xvzf ${share_archive} -C $out
    '';

    #installPhase = ''
    #    mkdir -p $out
    #    cp -r $share_archive $out/share
    #'';
}
