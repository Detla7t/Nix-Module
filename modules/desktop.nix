{
    config, 
    pkgs,
    lib,
    ...
}: 
let 

in 
{
    imports =
    [ # paths of other modules
    ];

    options = {
        # option declarations
        essence = {
            desktopSettings = {
                Cinnamon = {
                    enable =  lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = ''
                            Enable the cinnamon desktop enviroment
                        '';
                    };
                    packages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [];
                        description = ''
                            Packages to install when cinnamon is enabled.
                        '';
                    };
                    excludePackages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [];
                        description = ''
                            Packages to exclude from KDE if it is enabled.
                        '';
                    };
                };
                Cosmic = {
                    enable =  lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = ''
                            Enable the cosmic desktop enviroment
                        '';
                    };
                    packages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [];
                        description = ''
                            Packages to install when cosmic is enabled.
                        '';
                    };
                };
                Gnome = {
                    enable =  lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = ''
                            Enable the gnome desktop enviroment
                        '';
                    };
                    packages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [];
                        description = ''
                            Packages to install when gnome is enabled.
                        '';
                    };
                    excludePackages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [];
                        description = ''
                            Packages to exclude from KDE if it is enabled.
                        '';
                    };
                };
                Hypr = {
                    enable =  lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = ''
                            Enable the hyprland desktop enviroment
                        '';
                    };
                    packages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [];
                        description = ''
                            Packages to install when hyprland is enabled.
                        '';
                    };
                };
                KDE = {
                    enable =  lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = ''
                            Enable the KDE desktop enviroment
                        '';
                    };
                    packages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [];
                        description = ''
                            Packages to install when KDE is enabled.
                        '';
                    };
                    excludePackages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [];
                        description = ''
                            Packages to exclude from KDE if it is enabled.
                        '';
                    };
                };
                Terminal = {
                    enable =  lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = ''
                            Enable the terminal related settings
                        '';
                    };
                    packages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [];
                        description = ''
                            Packages to install when terminal is enabled.
                        '';
                    };
                };
                themeSettings = {
                    enable =  lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = ''
                            Enable the theming.
                        '';
                    };
                    # colorscheme = lib.mkOption {
                    #     type = lib.types.str;
                    #     default = true;
                    #     description = ''
                    #         Enable the theming.
                    #     '';
                    # };
                    wallpaper = lib.mkOption {
                        type = lib.types.either lib.types.path lib.types.str;
                        default = true;
                        description = ''
                            Wallpaper Path or storepath example:
                                "''${pkgs.wallpapers}/share/wallpapers/Warm_Cozy_rooms/Cozy_Jungle_House.jxl";
                        '';
                    };
                };
            };
        };
    };

    config = 
    let
        cfg = config.essence.desktopSettings;
    in 
    lib.mkMerge [
        (lib.mkIf (cfg.Cinnamon.enable == true) {
            environment.systemPackages = cfg.packages.packages;
            services = {
                cinnamon.apps.enable = true;
                xserver = {
                    enable = true; #TODO CHECK IF THIS IS NEEDED FOR GNOME
                    desktopManager.cinnamon.enable = true;
                };
            };
        })
        (lib.mkIf (cfg.Cosmic.enable == true) {
            environment.systemPackages = cfg.Cosmic.packages;
            services.xserver = {
                #enable = true; 
            };
        })
        (lib.mkIf (cfg.Gnome.enable == true) {
            environment.systemPackages = cfg.Gnome.packages;
            services.xserver = {
                #enable = true; #TODO CHECK IF THIS IS NEEDED FOR GNOME
                displayManager.gdm.enable = true;
                desktopManager.gnome.enable = true;
            };
        })
        (lib.mkIf (cfg.Hypr.enable == true) {
            environment = {
                sessionVariables = {
                    WLR_NO_HARDWARE_CURSORS = "1"; # If your cursor becomes invisible
                    NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
                };
                systemPackages = cfg.Hypr.packages;
            };
            programs = { 
                hyprland = {
                    enable = true;
                    withUWSM = true;
                    xwayland.enable = true;
                };
                hyprlock.enable = true;
            };
            xdg = {
                portal = {
                    enable = true;
                    wlr = {
                        enable = true;
                    };
                };
            };
        })  
        (lib.mkIf (cfg.KDE.enable == true) {
            environment= {
                plasma6.excludePackages = cfg.KDE.excludePackages;
                # sessionVariables = {
                #     KWIN_DRM_DEVICES = "/dev/dri/card1"; # This Sets the default KWIN GPU device to what ever card is set
                # };
                systemPackages = cfg.KDE.packages;
            };
            services = {
                # Enable the KDE Plasma Desktop Environment.
                desktopManager.plasma6.enable = lib.mkDefault true;
                desktopManager.plasma6.notoPackage = lib.mkDefault pkgs.inter-nerdfont;
                desktopManager.plasma6.enableQt5Integration = lib.mkDefault false;
            };
            #setup_kde = {
            #    enable = true;
            #    text =  local_lib.Copy_Folder "${kde.folder}/.config" "${home_directory}/.config";
            #};
            # TODO have kscreenlockerrc file share the same picture as the normal lockscreen

            
        })
        (lib.mkIf (cfg.Terminal.enable == true) {
            environment.systemPackages = cfg.Terminal.packages;
        })
    ];
}