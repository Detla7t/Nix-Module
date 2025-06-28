{
    config,
    lib,
    pkgs,
    ...
}: 
let 
    cfg = config.essence.user;
    useropts = 
        { name, options, ... }: #{
            let
                audio_module = (import ./user/audio.nix {inherit lib; inherit pkgs;});
                desktop_module = (import ./user/desktop.nix {inherit pkgs; inherit lib;});
                file_module = (import ./user/files.nix {inherit config; inherit lib;});
                gaming_module = (import ./user/gaming.nix {inherit lib; inherit pkgs;});
                productivity_module = (import ./user/productivity.nix {inherit lib; inherit pkgs;});
                service_module = (import ./user/service.nix {inherit name; inherit config; inherit lib;});
            in 
            {
            options = {
                name = lib.mkOption {
                    type = lib.types.str;
                    apply = x: assert (builtins.stringLength x < 32 || abort "Username '${x}' is longer than 31 characters which is not allowed!"); x;
                };
                files = lib.mkOption {
                    default = { };
                    type = lib.types.submodule {
                        options = file_module.options; 
                    };
                };
                function = {
                    audio = lib.mkOption {
                        default = { };
                        type = lib.types.submodule {
                            options = audio_module.options;
                        };
                    };
                    gaming = lib.mkOption {
                        default = { };
                        type = lib.types.submodule {
                            options = gaming_module.options; 
                        };
                    }; 
                    productivity = lib.mkOption {
                        default = {};
                        type = lib.types.submodule {
                            options = productivity_module.options;
                        };
                    };
                };
                service = lib.mkOption {
                    default = { };
                    type = lib.types.submodule {
                        options = service_module.options; 
                    };
                };
                settings = {
                    desktop = lib.mkOption {
                        type = lib.types.submodule {
                            options = desktop_module.options; 
                        };
                    };
                    home = lib.mkOption {
                        type = lib.types.str;
                        default = "/home/${name}";
                        description = ''Path to user's home folder'';
                    };
                };
            };
            config = { 
                name = lib.mkDefault name;
            };
        };
in 
{
    options = {
        essence.user = lib.mkOption {
            default = {};
            type = lib.types.attrsOf (lib.types.submodule useropts);
        };
    };
    config = 
    let
        builder = import ./functions/service_builder.nix {
            inherit lib;
            inherit pkgs;
        }; 
        programs_builder = x:
            #builtins.trace x.function.productivity.development.enable
            {
                gamescope.enable = lib.mkDefault x.function.gaming.enable;
                git.enable = lib.mkDefault true; #Yea... this used to be toggleable but you'll thank me later for leaving this true by default
                # Note to be able to push commits to github repos using Lazygit login using <Username>:<Github_Personal_Access_Token>
                # TODO in Jan 01 2026 Generate a new <Github_Personal_Access_Token> https://github.com/settings/tokens
                lazygit.enable = lib.mkDefault x.function.productivity.development.enable; #as a test terminal git ui
                steam = lib.mkIf (x.function.gaming.enable == true) {
                    enable = lib.mkDefault true;
                    extest.enable = lib.mkDefault true; #translate X11 input events to uinput events (e.g. for using Steam Input on Wayland) .
                    #extraCompatPackages = with pkgs; [ proton-ge-bin ];
                    gamescopeSession.enable = lib.mkDefault true;
                    localNetworkGameTransfers.openFirewall = lib.mkDefault true;
                    protontricks.enable = lib.mkDefault true;
                    remotePlay.openFirewall = lib.mkDefault true;
                };
            };

    in 
        lib.mkIf (cfg != { }) (lib.mkMerge [
            {
                users.users = 
                    (lib.mapAttrs (
                        user: setting:
                            { 
                                extraGroups = []
                                    # Audio Groups
                                    ++ (if (setting.function.audio.enable == true) then [ "audio" ] else [])
                                ;
                                packages = []
                                    # Audio Packages
                                    ++ (if (setting.function.audio.enable == true) then
                                        setting.function.audio.packages
                                    else [])
                                    # Gaming Packages
                                    ++ (if (setting.function.gaming.enable == true) then 
                                        setting.function.gaming.packages
                                    else []) 
                                    ++ (if (setting.function.gaming.emulator.enable == true) then 
                                        setting.function.gaming.emulator.packages 
                                    else [])
                                    ++ (if (setting.function.gaming.vr.enable == true) then 
                                        setting.function.gaming.vr.packages
                                    else [])
                                    # Productivity packages
                                    ++ (if (setting.function.productivity.administration.enable == true) then
                                        setting.function.productivity.administration.packages
                                    else [])
                                    ++ (if (setting.function.productivity.development.enable == true) then
                                        setting.function.productivity.development.packages
                                    else [])
                                    ++ (if (setting.function.productivity.office.enable == true) then
                                        setting.function.productivity.office.packages
                                    else [])
                                ; 
                            }
                    ) cfg);
            }
            {
                programs = programs_builder (lib.attrsets.mergeAttrsList (builtins.attrValues cfg));
            }
            {
                systemd.user.services = lib.mkMerge (builder.build_a_service cfg);
                system.userActivationScripts = {
                    startup = { 
                        text = builtins.concatStringsSep "\n" 
                            (map (
                                settings:
                                    # Note if calling Programs you they should be run as the current system as follows
                                    "/run/current-system/sw/bin/systemctl --user start ${settings.service.activation.name}"
                            ) (builtins.attrValues cfg));
                    };
                };
            }
        ]);
}