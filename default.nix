{
    config, 
    lib, 
    pkgs,
    ...
}: 
let 
    cfg = config.essence;
    #cfg_user = config.essence.user;
in 

{
    imports =
    [ # paths of other modules
    
        ./modules/audio.nix
        ./modules/desktop.nix
        ./modules/graphics.nix
        ./modules/lockscreen.nix
        ./modules/user.nix
    ];

    # TODO Pull in Serivce Creation into this file. as that is the only way to build out togglable service service scripts for each user

    options = {
        essence = {
            basics = {
                enable = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = ''
                        Enable the standard system basics I like on a minimal system.
                    '';
                };
            };
            programs = {
                git = {
                    username = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        description = ''
                            The username given to git.
                        '';
                    };
                    email = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        description = ''
                            The email given to git.
                        '';
                    };
                    token = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        description = ''
                            The token given to git.
                        '';
                    };
                };
            };
            # user = lib.mkOption {
            #     default = { };
            #     type = lib.types.attrsOf (lib.types.submodule (import ./user/. {
            #         inherit lib; 
            #         inherit pkgs; 
            #         inherit config;
            #     }));
            # };
        };
    };

    config = 
    let
        builder = import ./modules/functions/service_builder.nix {
            inherit lib;
            inherit pkgs;
        }; 
        programs_builder = x:
            builtins.trace x.function.productivity.development.enable
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
    lib.mkMerge [
        #(lib.mkIf (config.essence.user != { }) lib.mkMerge [
        #    # {
        #    #     users.users = 
        #    #         (lib.mapAttrs (
        #    #             user: setting:
        #    #                 { 
        #    #                     extraGroups = []
        #    #                         # Audio Groups
        #    #                         ++ (if (setting.function.audio.enable == true) then [ "audio" ] else [])
        #    #                     ;
        #    #                     packages = []
        #    #                         # Audio Packages
        #    #                         ++ (if (setting.function.audio.enable == true) then
        #    #                             setting.function.audio.packages
        #    #                         else [])
        #    #                         # Gaming Packages
        #    #                         ++ (if (setting.function.gaming.enable == true) then 
        #    #                             setting.function.gaming.packages
        #    #                         else []) 
        #    #                         ++ (if (setting.function.gaming.emulator.enable == true) then 
        #    #                             setting.function.gaming.emulator.packages 
        #    #                         else [])
        #    #                         ++ (if (setting.function.gaming.vr.enable == true) then 
        #    #                             setting.function.gaming.vr.packages
        #    #                         else [])
        #    #                         # Productivity packages
        #    #                         ++ (if (setting.function.productivity.administration.enable == true) then
        #    #                             setting.function.productivity.administration.packages
        #    #                         else [])
        #    #                         ++ (if (setting.function.productivity.development.enable == true) then
        #    #                             setting.function.productivity.development.packages
        #    #                         else [])
        #    #                         ++ (if (setting.function.productivity.office.enable == true) then
        #    #                             setting.function.productivity.office.packages
        #    #                         else [])
        #    #                     ; 
        #    #                 }
        #    #         ) config.essence.user);
        #    # }
        #    {
        #        programs = programs_builder (lib.attrsets.mergeAttrsList (builtins.attrValues config.essence.user));
        #    }
        #    {
        #        systemd.user.services = lib.mkMerge (builder.build_a_service config.essence.user);
        #    }
        #])
        {

            environment = (lib.mkIf (config.essence.basics.enable == true) {
                binsh = "${pkgs.dash}/bin/dash"; #set default sh to be dash This is an faster bash interpreter
                systemPackages = with pkgs; [
                    btop # Resource Monitor
                    cifs-utils # Samba client utils
                    ffmpeg # Multimedia framework
                    imagemagick
                    jq
                    rar # Utility for RAR archives
                    vim
                    wget
                ];
            });

            fonts = (lib.mkIf (config.essence.basics.enable == true) {
                packages = with pkgs; [
                    inter-nerdfont
                    nerd-fonts.bigblue-terminal
                    nerd-fonts.dejavu-sans-mono
                    nerd-fonts.gohufont
                    nerd-fonts.hack
                    nerd-fonts.jetbrains-mono
                ];
            });

            nix = (lib.mkIf (config.essence.basics.enable == true) {
                settings = {
                    # Nix automatically detects files in the store that have identical contents, and replaces them with hard links to a single copy.
                    auto-optimise-store = lib.mkDefault true; 
                    # Enable Flakes
                    experimental-features = [ "nix-command" "flakes" ];
                };
            });

            programs = (lib.mkIf (config.essence.basics.enable == true) {
                appimage = {
                    enable = true;
                    binfmt = true;
                };
                bash = {
                    completion.enable = lib.mkDefault true;
                    enableLsColors = lib.mkDefault true;
                    #shellAliases = {};
                };
                firefox.enable = lib.mkDefault true; # Add a web browser so user can't be stupid unless they disable
                git = {
                    enable = lib.mkDefault true; # Source Code Control so that config can always be managed
                    package = pkgs.git;
                    config = [
                        {
                            github = (if (config.essence.programs.git.token != "") then { #DO NOT CHANGE THIS IT WILL THROW AN ERROR WITH mkIf DONT BOTHER
                                user = "${config.essence.programs.git.username}";
                                password = "${config.essence.programs.git.token}";
                            } else {
                                user = "${config.essence.programs.git.username}";
                            });
                            user = {
                                email = "${config.essence.programs.git.email}";
                                name = "${config.essence.programs.git.username}";
                            };
                            init = {
                                defaultBranch = "main";
                            };
                            url = {
                                "https://github.com/" = {
                                    insteadOf = [
                                        "gh:"
                                        "github:"
                                    ];
                                };
                            };
                        }
                    ];
                };
                nano = {
                    enable = lib.mkDefault true;
                    syntaxHighlight = lib.mkDefault true;
                };
                nh = {
                    enable = lib.mkDefault true;
                    clean = {
                        dates = "weekly";
                        enable = lib.mkDefault true;
                        extraArgs = "--keep 30 --keep-since 30d";
                    };
                };
                zsh = {
                    enable = lib.mkDefault true; # make sure user has a working shell
                    setOptions = [
                        "HIST_IGNORE_DUPS"
                        "SHARE_HISTORY"
                        "HIST_FCNTL_LOCK"
                        "HIST_EXPIRE_DUPS_FIRST"
                        "HIST_SAVE_NO_DUPS"
                    ];
                    syntaxHighlighting.enable = true;
                };
            });
            xdg = {
                autostart.enable = lib.mkDefault true;
                menus.enable = lib.mkDefault true;
            };
        }
    ];
}