{ stdenv, pkgs, fetchurl, lib, pkg-config, dbus, fontconfig, freetype, glib, glibc, libsForQt5, libGL, libxkbcommon, xorg, zlib, makeWrapper, autoPatchelfHook, gcc-unwrapped, makeDesktopItem, 
    extraConfig ? "", tomlName ? ".demonsaw.toml", tomlLocation ? ''$HOME/.config/'', buildAnonProfile ? true
}:
stdenv.mkDerivation rec {
    pname = "demonsaw";
    version = "4.2.1";
    
    #current_folder = builtins.toString ./.;

    src = builtins.fetchurl {
        url = "https://www.demonsaw.com/download/demonsaw_nix_64.tar.bz2"; #Demonsaw tar direct url
        #url = "file://${current_folder}/demonsaw_nix_64.tar.bz2";
        #sha256 = lib.fakeSha256;
        sha256 = "sha256-A6Md5YCPbOK4u3IfcI39WTiWV9vLyq5y/v+/mQVYQt8=";
    };

    dontBuild = true;
    dontWrapQtApps = false;
    nativeBuildInputs = [ 
        makeWrapper 
        autoPatchelfHook 
    ];

    buildInputs = [ 
        dbus 
        fontconfig 
        freetype 
        gcc-unwrapped 
        glib 
        glibc 
        libsForQt5.full 
        libGL 
        libxkbcommon 
        stdenv.cc.cc.lib
        xorg.libX11 
        zlib 
    ];

    unpackPhase = ''
        mkdir -p $out
        tar -xvf $src > $pname
    '';

    desktopItem = pkgs.makeDesktopItem rec {
        name = "demonsaw";
        desktopName = "Demonsaw";
        genericName = "Private Messenger";
        icon = "${name}";
        exec = "${name} %U";
        keywords = [
            "ds4"
            "demonsaw"
            "messenger"
            "chat"
        ];
        categories = [
            "Network"
            "InstantMessaging"
            "Chat"
        ];
    };

    # Toml Example Config
    # This File is not required but does lock the configuration and block the demonsaw config from being made in tomlLocation
    #    "example.toml" = ''
    #        [[client]]
    #            enabled = true	
    #            name = "Example Client #1"
    #            color = "0c9bdc"
    #            [[client.router]]
    #                enabled = true		
    #                name = "Router 1"		
    #                address = "router.demonsaw.com"
    #                port = 80
    #            [[client.share]]
    #                enabled = false
    #                path = "C:/share1"		
    #            [[client.share]]
    #                enabled = false
    #                path = "C:/share2"
    #        [[client]]
    #            enabled = false
    #            name = "Example Client #2"	
    #            color = "18b6ad"	
    #            [[client.router]]
    #                enabled = true		
    #                name = "Router #1"		
    #                address = "router.demonsaw.com"
    #                port = 80
    #            [[client.share]]
    #                enabled = false
    #                path = "C:/share1"
    #            [[client.share]]
    #                enabled = false
    #                path = "C:/share2"
    #   '';
    
    generator_script = pkgs.writeShellScript "generate_demonsaw_toml.sh" ''
        echo "Checking if \"${tomlLocation}\" exists "
        if [ ! -d "${tomlLocation}" ]; then
            echo "Directory not found. making folder in \"${tomlLocation}\""
            mkdir -p "${tomlLocation}"
        fi
        echo "Checking if \"${tomlName}\" exists"
        if [ ! -f "${tomlLocation}${tomlName}" ]; then
            echo "File not found. making file."
            touch ${tomlLocation}${tomlName}
        fi
    '';

    preBuild = ''
        addAutoPatchelfSearchPath ${pkgs.libsForQt5.full}/lib/qt-6/plugins/platforms:$out/$pname/lib/platforms
    '';

    #install -m755 $out/$pname/demonsaw $out/bin/demonsaw-patched

    installPhase = ''
        mkdir -p $out/bin
        cp -r $pname $out/$pname
        
        ${lib.optionalString (extraConfig == "") ''
        echo -e "Building local profile wrapper"
        cp $generator_script $out/bin/generate_demonsaw_toml.sh
        chmod +x $out/bin/generate_demonsaw_toml.sh
        makeWrapper $out/$pname/demonsaw $out/bin/demonsaw \
            --chdir $out/$pname \
            --prefix LD_LIBRARY_PATH : "$out/$pname/lib:${lib.makeLibraryPath [ dbus fontconfig freetype glib glibc libsForQt5.full libGL libxkbcommon xorg.libX11 zlib gcc-unwrapped stdenv.cc.cc.lib]}" \
            --prefix QT_QPA_PLATFORM : xcb \
            --prefix QT_PLUGIN_PATH : ${pkgs.libsForQt5.full}/lib/qt-6/plugins/platforms:$out/$pname/lib/platforms \
            --prefix QT_DEBUG_PLUGINS : 1 \
            --run $out/bin/generate_demonsaw_toml.sh \
            --add-flags '${tomlLocation}${tomlName}'
        makeWrapper $out/$pname/demonsaw_cli $out/bin/demonsaw_cli \
            --chdir $out/$pname \
            --prefix LD_LIBRARY_PATH : "$out/$pname/lib:${lib.makeLibraryPath [ dbus fontconfig freetype glib glibc libsForQt5.full libGL libxkbcommon xorg.libX11 zlib gcc-unwrapped stdenv.cc.cc.lib]}" \
            --prefix QT_PLUGIN_PATH : ${pkgs.libsForQt5.full}/lib/qt-6/plugins/platforms:$out/$pname/lib/platforms \
            --prefix QT_DEBUG_PLUGINS : 1 \
            --run $out/bin/generate_demonsaw_toml.sh \
            --add-flags '${tomlLocation}${tomlName}'
        makeWrapper $out/$pname/demonsaw_router $out/bin/demonsaw_router \
            --chdir $out/$pname \
            --prefix LD_LIBRARY_PATH : "$out/$pname/lib:${lib.makeLibraryPath [ dbus fontconfig freetype glib glibc libsForQt5.full libGL libxkbcommon xorg.libX11 zlib gcc-unwrapped stdenv.cc.cc.lib]}" \
            --prefix QT_PLUGIN_PATH : ${pkgs.libsForQt5.full}/lib/qt-6/plugins/platforms:$out/$pname/lib/platforms \
            --prefix QT_DEBUG_PLUGINS : 1 \
            --run $out/bin/generate_demonsaw_toml.sh \
            --add-flags '${tomlLocation}${tomlName}'
        ''}
        ${lib.optionalString (extraConfig != "") ''
        echo -e "Building locked profile wrapper"
        echo '${extraConfig}' > $out/$pname/configured_demonsaw.toml
        makeWrapper $out/$pname/demonsaw $out/bin/demonsaw \
            --chdir $out/$pname \
            --prefix LD_LIBRARY_PATH : "$out/$pname/lib:${lib.makeLibraryPath [ dbus fontconfig freetype glib glibc libsForQt5.full libGL libxkbcommon xorg.libX11 zlib gcc-unwrapped stdenv.cc.cc.lib]}" \
            --prefix QT_QPA_PLATFORM : xcb \
            --prefix QT_PLUGIN_PATH : ${pkgs.libsForQt5.full}/lib/qt-6/plugins/platforms:$out/$pname/lib/platforms \
            --prefix QT_DEBUG_PLUGINS : 1 \
            --add-flags $out/$pname/configured_demonsaw.toml
        makeWrapper $out/$pname/demonsaw_cli $out/bin/demonsaw_cli \
            --chdir $out/$pname \
            --prefix LD_LIBRARY_PATH : "$out/$pname/lib:${lib.makeLibraryPath [ dbus fontconfig freetype glib glibc libsForQt5.full libGL libxkbcommon xorg.libX11 zlib gcc-unwrapped stdenv.cc.cc.lib]}" \
            --prefix QT_PLUGIN_PATH : ${pkgs.libsForQt5.full}/lib/qt-6/plugins/platforms:$out/$pname/lib/platforms \
            --prefix QT_DEBUG_PLUGINS : 1 \
            --add-flags $out/$pname/configured_demonsaw.toml
        makeWrapper $out/$pname/demonsaw_router $out/bin/demonsaw_router \
            --chdir $out/$pname \
            --prefix LD_LIBRARY_PATH : "$out/$pname/lib:${lib.makeLibraryPath [ dbus fontconfig freetype glib glibc libsForQt5.full libGL libxkbcommon xorg.libX11 zlib gcc-unwrapped stdenv.cc.cc.lib]}" \
            --prefix QT_PLUGIN_PATH : ${pkgs.libsForQt5.full}/lib/qt-6/plugins/platforms:$out/$pname/lib/platforms \
            --prefix QT_DEBUG_PLUGINS : 1 \
            --add-flags $out/$pname/configured_demonsaw.toml
        ''}
        ${lib.optionalString (buildAnonProfile == true) ''
        echo -e "Building anonymous wrapper"
        makeWrapper $out/$pname/demonsaw $out/bin/demonsaw-anon \
            --chdir $out/$pname \
            --prefix LD_LIBRARY_PATH : "$out/$pname/lib:${lib.makeLibraryPath [ dbus fontconfig freetype glib glibc libsForQt5.full libGL libxkbcommon xorg.libX11 zlib gcc-unwrapped stdenv.cc.cc.lib]}" \
            --prefix QT_QPA_PLATFORM : xcb \
            --prefix QT_PLUGIN_PATH : ${pkgs.libsForQt5.full}/lib/qt-6/plugins/platforms:$out/$pname/lib/platforms \
            --prefix QT_DEBUG_PLUGINS : 1
        makeWrapper $out/$pname/demonsaw_cli $out/bin/demonsaw-anon_cli \
            --chdir $out/$pname \
            --prefix LD_LIBRARY_PATH : "$out/$pname/lib:${lib.makeLibraryPath [ dbus fontconfig freetype glib glibc libsForQt5.full libGL libxkbcommon xorg.libX11 zlib gcc-unwrapped stdenv.cc.cc.lib]}" \
            --prefix QT_PLUGIN_PATH : ${pkgs.libsForQt5.full}/lib/qt-6/plugins/platforms:$out/$pname/lib/platforms \
            --prefix QT_DEBUG_PLUGINS : 1
        ''}

        # Setup application Icon
        mkdir -p "$out/share/icons/hicolor/128x128/apps"  # the long folder path is crucial, just using $out/share/icons does not work
        #Note $out/share/icons is equivelant to /run/current-system/sw/share/icons
        ln -s "$out/$pname/image/demonsaw.png" "$out/share/icons/hicolor/128x128/apps/demonsaw.png"

        # Create Desktop Item
        mkdir -p "$out/share/applications"
        ln -s "${desktopItem}"/share/applications/* "$out/share/applications/"

    '';

    postInstall = ''
    find "$out" -type f -exec remove-references-to -t ${stdenv.cc} '{}' +
    '';
    meta = with lib; {
        description = "An encrypted communications platform that allows you to chat, message, and transfer files";
        homepage = "https://www.demonsaw.com/";
        license = licenses.mit;
    };
}
