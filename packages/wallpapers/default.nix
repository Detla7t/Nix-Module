{ stdenv, pkgs, fetchurl, lib, pkg-config }:
stdenv.mkDerivation rec {
    pname = "wallpaper_pack";
    version = "0.0.6";

    current_folder = builtins.toString ./.;

    share_archive = ./share;

    #dontUnpack = true;
    dontBuild = true;
    dontInstall = true;
    #dontPatchShebangs = true;   # Reduces build time for this package by approximately 1 seconds
    #dontFixup = true;   # Skips long fixup phase that take ~13 seconds alone. due to it checking every file and there being alot of files

    unpackPhase = ''
        mkdir -p $out/share
        cp -r ${share_archive}/. $out/share
        #tar -xvzf ${share_archive} -C $out
    '';

    #installPhase = ''
    #    mkdir -p $out
    #    cp -r $share_archive $out/share
    #'';
}
