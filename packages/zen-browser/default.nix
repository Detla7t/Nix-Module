{
    appimageTools,
    lib,
    stdenv,
    callPackage,
    fetchurl,
    pkgs,
    ...
}:
let
    pname = "zen-browser";
    version = "1.12.8b";
    meta = {
        description = "A beautifully designed, privacy-focused, and feature packed firefox fork";
        homepage = "https://zen-browser.app/";
        license = lib.licenses.unfree;
        mainProgram = "zen-browser";
        maintainers = with lib.maintainers; [
            cig0
            eeedean
            crertel
        ];
        platforms = [
            "x86_64-linux"
        ];
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
    src = fetchurl {
        #url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
        url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
        hash = "sha256-974n8beJnJTCgC7a/jwyA7MDuhkY2FidX0iimTqIVIg=";
    };
    appimageContents = appimageTools.extractType2 { inherit pname version src; 
        #postExtract = ''
        #    substituteInPlace $out/zen-browser.desktop --replace-fail 'Exec=AppRun' 'Exec=zen'
        #'';
    };
    desktopItem = pkgs.makeDesktopItem rec {
        #TODO add a category to the desktop file so that it doesnt show up in lost and found
        name = "zen-browser";
        desktopName = "zen";
        genericName = "Web Browser";
        icon = "zen";
        exec = "zen-browser %U";
        keywords = [
            "zen"
            "zen browser"
            "zen-browser"
            "firefox"
            "browser"
        ];
        categories = [
            #"Network"
            #"InstantMessaging"
            #"Chat"
        ];
    };
in
appimageTools.wrapType2 {
    inherit
        meta
        pname
        version
        src
        ;

    #extraPkgs = pkgs: [ pkgs.ocl-icd ];

    extraInstallCommands = ''
        mkdir -p $out/share/applications
        cp -r ${appimageContents}/usr/share/icons $out/share
        #cp -r ${desktopItem}/share/applications/zen-browser.desktop $out/desktopfile.desktop
        install -m 444 -D ${desktopItem}/share/applications/zen-browser.desktop -t $out/share/applications
        #install -m 444 -D ${appimageContents}/zen-browser.desktop -t $out/share/applications
        #substituteInPlace $out/share/applications/zen-browser.desktop \
        #--replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=zen-browser'
    '';
}

