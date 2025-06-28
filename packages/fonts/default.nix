{ stdenvNoCC, fetchzip, pkgs, lib,
  enableWindowsFonts ? false
}:

let
    inter_version = "4.0";
    nerd_fonts_version = "3.3.0";
in stdenvNoCC.mkDerivation {
    name = "quick-nerdfonts";
    version = "0.0.2";
    #inherit inter_version;

    # TODO Move font fetchurl to a list like https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/data/fonts/nerdfonts/shas.nix
    # TODO Actually Test if fonts are properly installed by disabling nerdfonts
    # TODO Add automatic updater/update checker https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/data/fonts/nerdfonts/update.sh
    # TODO move all downloads to srcs like in the original nerdfonts package https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/data/fonts/nerdfonts/default.nix
    # NOTE this package format was ripped from https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/by-name/in/inter-nerdfont/package.nix#L39

    big_blue_terminal_font = builtins.fetchurl {
        url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nerd_fonts_version}/BigBlueTerminal.tar.xz";
        #sha256 = lib.fakeSha256;
        sha256 = "0ddaqn48fg676dx3bwcr0qplrx8wd0hh0hs2g9vzccbc3h84igs4";
    };

    deja_vu_sans_mono = builtins.fetchurl {
        url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nerd_fonts_version}/DejaVuSansMono.tar.xz";
        #sha256 = lib.fakeSha256;
        sha256 = "1i808j6n3isrfqnnich26mvc7kbqb8iymrgci0iffvqbfk7rsbg0";
    };

    goho_font = builtins.fetchurl {
        url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nerd_fonts_version}/Gohu.tar.xz";
        #sha256 = lib.fakeSha256;
        sha256 = "09shaj88w0z6jl1bp9d6cl8bf6fb7ygim1iq75vw2gdm3v7yyhys";
    };

    hack_font = builtins.fetchurl {
        url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nerd_fonts_version}/Hack.tar.xz";
        #sha256 = lib.fakeSha256;
        sha256 = "02g9hshcsndg58x99qhj4y3vixwnivj6yk316mgil6cr9d7555zp";
    };

    # NOTE noto font adds 900mb of addition space usage if enabled
    #noto_font = builtins.fetchurl {
    #    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nerd_fonts_version}/Noto.tar.xz";
    #    #sha256 = lib.fakeSha256;
    #    sha256 = "09v4ymim41m7ry938hahs6ams43pz9bhdx85csa6bxfvvk8k0sjm";
    #};

    #Inter_font = fetchzip {
    src = fetchzip {
        url = "https://github.com/rsms/inter/releases/download/v${inter_version}/Inter-${inter_version}.zip";
        stripRoot = false;
        #sha256 = lib.fakeSha256;
        hash = "sha256-hFK7xFJt69n+98+juWgMvt+zeB9nDkc8nsR8vohrFIc=";
    };

    installPhase = ''
        runHook preInstall

        mkdir -p $out/share/fonts/truetype
        nerd-font-patcher Inter.ttc
        cp 'Inter Nerd Font.ttc' $out/share/fonts/truetype/InterNerdFont.tcc
        cp *.ttf $out/share/fonts/truetype

        mkdir -p ./Nerdfonts
        tar -xf $big_blue_terminal_font -C ./Nerdfonts
        tar -xf $deja_vu_sans_mono -C ./Nerdfonts
        tar -xf $goho_font -C ./Nerdfonts
        tar -xf $hack_font -C ./Nerdfonts
        cd ./Nerdfonts
        find -name \*.otf -exec mkdir -p $out/share/fonts/opentype/NerdFonts \; -exec mv {} $out/share/fonts/opentype/NerdFonts \;
        find -name \*.ttf -exec mkdir -p $out/share/fonts/truetype/NerdFonts \; -exec mv {} $out/share/fonts/truetype/NerdFonts \;
        ${lib.optionalString (!enableWindowsFonts) ''
            rm -rfv $out/share/fonts/opentype/NerdFonts/*Windows\ Compatible.*
            rm -rfv $out/share/fonts/truetype/NerdFonts/*Windows\ Compatible.*
        ''}


        runHook postInstall
    '';

    buildInputs = builtins.attrValues {
        inherit (pkgs)
            fontforge
            nerd-font-patcher;
    };
}
