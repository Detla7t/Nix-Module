{ 
    lib,
    pkgs,
    ...
}: 
{
    build_a_service = cfg:
    [
        (lib.mapAttrs' (
            user: settings:
            lib.nameValuePair "${settings.service.failure.name}" (lib.mkIf (settings.service.failure.enable == true) {
                script = settings.service.failure.script;
                serviceConfig.Type = settings.service.failure.type;
            })
        ) cfg)
        (lib.mapAttrs' (
            user: settings:
            let 
                local_lib = (import ../lib/local_lib.nix { inherit lib; inherit pkgs;});
                cfg_files = settings.files;
                cfg_home = settings.settings.home;
                mkdirStrings = (if (cfg_files.makeFolders != []) then builtins.concatStringsSep "\n" (map (x: local_lib.mkdir x) cfg_files.makeFolders)  else "");
                linkPackageStrings = (if (cfg_files.linkPackage != []) then builtins.concatStringsSep "\n" (local_lib.generic_map_file_list cfg_files.linkPackage local_lib.Link_file) else "");
                simpleLinkStrings = (if (cfg_files.simpleLink != []) then builtins.concatStringsSep "\n" (local_lib.generic_map_file_list cfg_files.simpleLink local_lib.Simple_Force_Link) else "");
                simpleCopyFileStrings = (if (cfg_files.simpleCopyFiles != []) then builtins.concatStringsSep "\n" (local_lib.generic_map_file_list cfg_files.simpleCopyFiles local_lib.Simple_Copy_file) else "");
                copyFoldersStrings = (if (cfg_files.copyFolders != []) then builtins.concatStringsSep "\n" (local_lib.generic_map_file_list cfg_files.copyFolders local_lib.Copy_Folder) else "");
                #copyFilesString = (if (cfg_files.copyFiles != []) then concatenateEnabledStrings cfg_files.copyFiles else "");
                link_steam_directory = 
                let 
                    remote_directory = (if (cfg_files.linkSteam.location != "") then cfg_files.linkSteam.location else "/home/${user.name}/.local/share/Steam");
                in 
                (if (cfg_files.linkSteam.enable == true) then {
                    script = builtins.concatStringsSep "\n" [
                        ''echo "starting steam folder linking"''
                        ''mkdir -p "${cfg_home}/.steam"''
                        (local_lib.Simple_Force_Link "${cfg_home}/.local/share/Steam/ubuntu12_32"   "${cfg_home}/.steam/bin32")
                        (local_lib.Simple_Force_Link "${cfg_home}/.steam/bin32"                     "${cfg_home}/.steam/bin")
                        (local_lib.Simple_Force_Link "${cfg_home}/.local/share/Steam/ubuntu12_64"   "${cfg_home}/.steam/bin64")
                        (local_lib.Simple_Force_Link "${cfg_home}/.local/share/Steam"               "${cfg_home}/.steam/root")
                        (local_lib.Simple_Force_Link "${cfg_home}/.local/share/Steam/linux32"       "${cfg_home}/.steam/sdk32")
                        (local_lib.Simple_Force_Link "${cfg_home}/.local/share/Steam/linux64"       "${cfg_home}/.steam/sdk64")
                        (local_lib.Simple_Force_Link "${cfg_home}/.local/share/Steam"               "${cfg_home}/.steam/steam")
                        (local_lib.Simple_Force_Link "${remote_directory}"                          "${cfg_home}/.local/share/Steam")
                    ];
                } else { script = ""; });
                link_home_directory = 
                    let 
                        remote_directory = cfg_files.homeFolders.location;
                    in 
                    (if (cfg_files.homeFolders.enable == true && cfg_files.homeFolders.location != "") then {
                        script = builtins.concatStringsSep "\n" [
                            ''echo "starting home folder linking"''
                            (local_lib.Simple_Force_Link "${remote_directory}/Documents" "${cfg_home}/Documents")
                            (local_lib.Simple_Force_Link "${remote_directory}/Downloads" "${cfg_home}/Downloads")
                            (local_lib.Simple_Force_Link "${remote_directory}/Games"     "${cfg_home}/Games")
                            (local_lib.Simple_Force_Link "${remote_directory}/Music"     "${cfg_home}/Music")
                            (local_lib.Simple_Force_Link "${remote_directory}/Pictures"  "${cfg_home}/Pictures")
                            (local_lib.Simple_Force_Link "${remote_directory}/Programs"  "${cfg_home}/Programs")
                            (local_lib.Simple_Force_Link "${remote_directory}/Public"    "${cfg_home}/Public")
                            (local_lib.Simple_Force_Link "${remote_directory}/Videos"    "${cfg_home}/Videos")
                        ];
                    } else { script = ""; });
                KDE_wallpaper_script = 
                    (if (settings.settings.desktop.wallpaper != "" || settings.settings.desktop.KDE.wallpaper != "") then 
                        ''
                             echo "Starting set_wallpaper"
                             {
                             /run/current-system/sw/bin/dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript 'string:
                             var Desktops = desktops();                                                                                                                       
                             for (i=0;i<Desktops.length;i++) {
                                     d = Desktops[i];
                                     d.wallpaperPlugin = "org.kde.image";
                                     d.currentConfigGroup = Array("Wallpaper",
                                                                 "org.kde.image",
                                                                 "General");
                                     d.writeConfig("Image", "file://${(if (settings.settings.desktop.KDE.wallpaper != "") then settings.settings.desktop.KDE.wallpaper else settings.settings.desktop.wallpaper)}");
                             }'
                             } || {
                                 echo "Failed set_wallpaper"
                             }
                         ''
                     else "");
            in
            #    builtins.trace settings
            #    builtins.trace settings.service
            lib.nameValuePair "${settings.service.activation.name}" (lib.mkIf (settings.service.activation.enable == true) {
                script = 
                    builtins.concatStringsSep "\n" [ 
                        settings.service.activation.preScript 
                        mkdirStrings
                        linkPackageStrings
                        simpleLinkStrings
                        simpleCopyFileStrings
                        copyFoldersStrings           
                        #copyFilesString
                        link_home_directory.script
                        link_steam_directory.script
                        settings.service.activation.script 
                        KDE_wallpaper_script
                        settings.service.activation.postScript
                    ];
                onFailure = (if settings.service.failure.enable == true then [ "${settings.service.failure.name}.service" ] else []);
                serviceConfig.Type = settings.service.activation.type;
                wantedBy = settings.service.activation.wantedBy;
            }) 
        ) cfg)
    ];
}