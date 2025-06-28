{ stdenv, pkgs, fetchurl, lib, pkg-config }:
stdenv.mkDerivation rec {
    pname = "custom_theme_pack";
    version = "0.0.7";

    current_folder = builtins.toString ./.;

    #icon_theme_name = "We10X";
    #icon_theme_file = builtins.fetchurl {#fetchTarball {#
    #    url = "file://${current_folder}/We10X.tar.gz";
    #    #url = "./We10X.tar.gz";
    #    #sha256 = "0000000000000000000000000000000000000000000000000000";
    #    sha256 = "0z2qkp53dna9v8lsm1y4krhn42v1ka3bhvv3gj9qfxrmyrrdm10a";
    #};

    share_archive = builtins.fetchurl {#fetchTarball {#
        url = "file://${current_folder}/share.tar.gz";
        #sha256 = lib.fakeSha256;
        sha256 = "0djw1xq1j7amji6ylb6kvnrqbhq62cddmkra1pywncsi4bbdm2kz";
    };

    dontBuild = true;
    dontPatchShebangs = true;   # Reduces build time for this package by approximately 1 seconds
    dontFixup = true;   # Skips long fixup phase that take ~13 seconds alone. due to it checking every file and there being alot of files

    unpackPhase = ''
        mkdir -p $out
        tar -xvzf ${share_archive} #-C ${builtins.placeholder "out"}/share/icons
        #cd share/icons
        #tar -xvzf share/icons/We10X.tar.gz -C share/icons
        #rm share/icons/We10X.tar.gz
    '';

    installPhase = ''
        mkdir -p $out/share/icons
        cp -r share $out
    '';
}
