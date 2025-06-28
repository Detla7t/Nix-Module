{
    config, 
    pkgs,
    lib,
    ...
}: {
    imports =
    [ # paths of other modules
    ];

    options = {
        # option declarations
        essence = {
            lockscreenSettings = {
                sddm = {
                    enable = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = ''
                            Enable sddm as your lockscreen
                        '';
                    };
                    astronaut = {
                        enable = lib.mkOption {
                            type = lib.types.bool;
                            default = false;
                            description = ''
                                Enable sddm-astronaut as your lockscreen theme
                            '';
                        };
                        background = lib.mkOption {
                            type = lib.types.either lib.types.path lib.types.str;
                            #default = "";
                            description = ''
                                Set the Sddm background image as either a Path or storepath example:
                                    "''${pkgs.wallpapers}/share/wallpapers/Warm_Cozy_rooms/Cozy_Jungle_House.jxl";
                            '';
                        };
                        #color = {
                        #
                        #};
                        font = {
                            name = lib.mkOption {
                                type = lib.types.str;
                                default = "Hack Nerd Font";
                                description = ''
                                    The name of the font to use for sddm-astronaut
                                '';
                            };
                            size = lib.mkOption {
                                type = lib.types.str;
                                default = "11";
                                description = ''
                                    The font size for sddm-astronaut
                                '';
                            };
                        };
                        form = {
                            background.enable = lib.mkOption {
                                type = lib.types.str;
                                default = "false";
                                description = ''
                                    Enable sddm-astronaut form background
                                '';
                            };
                            position = lib.mkOption {
                                type = lib.types.str;
                                default = "center";
                                description = ''
                                    Enable sddm-astronaut form location
                                '';
                            };
                        };
                        format = {
                            time = lib.mkOption {
                                type = lib.types.str;
                                default = "HH:mm:ss";
                                description = ''
                                    Enable sddm-astronaut form location
                                '';
                            };
                            date = lib.mkOption {
                                type = lib.types.str;
                                default = "ddd d/MM/yyyy";
                                description = ''
                                    Enable sddm-astronaut form location
                                '';
                            };
                        };
                        screen = {
                            height = lib.mkOption {
                                type = lib.types.str;
                                default = "2160";
                                description = ''
                                    Set Screen height 
                                '';
                            };
                            width = lib.mkOption {
                                type = lib.types.str;
                                default = "3840";
                                description = ''
                                    Set Screen width
                                '';
                            };
                        };
                    };
                    catppuccin = {
                        enable = lib.mkOption {
                            type = lib.types.bool;
                            default = false;
                            description = ''
                                Enable sddm-catppuccin as your lockscreen theme.
                            '';
                        };
                        background = lib.mkOption {
                            type = lib.types.either lib.types.path lib.types.str;
                            default = "";
                            description = ''
                                Set the Sddm background image as either a Path or storepath example:
                                    "''${pkgs.wallpapers}/share/wallpapers/Warm_Cozy_rooms/Cozy_Jungle_House.jxl";
                            '';
                        };
                        flavor = lib.mkOption {
                            type = lib.types.str;
                            default = "mocha";
                            description = ''
                                The catppuccin color flavor
                            '';
                        };
                        font = {
                            name = lib.mkOption {
                                type = lib.types.str;
                                default = "Hack Nerd Font";
                                description = ''
                                    The name of the font to use for sddm-astronaut.
                                '';
                            };
                            size = lib.mkOption {
                                type = lib.types.str;
                                default = "11";
                                description = ''
                                    The font size for sddm-astronaut.
                                '';
                            };
                        };
                    };
                };
            };
        };
    };

    config = 
    let 
        cfg = config.essence.lockscreenSettings.sddm;
    in 
    {
        environment = lib.mkMerge [
            (lib.mkIf (cfg.astronaut.enable == true) {
                systemPackages = [
                    #kdePackages.qtvirtualkeyboard # is the virtual keyboard for sddm-astronaut
                    (pkgs.sddm-astronaut.override {
                        #https://github.com/Keyitdev/sddm-astronaut-theme/blob/master/Themes/pixel_sakura.conf
                        themeConfig = { 
                            #################### General ####################

                                ScreenWidth="${cfg.astronaut.screen.width}";
                                ScreenHeight="${cfg.astronaut.screen.height}";
                                ScreenPadding="";
                                # Default 0, Options: from 0 to min(screen width/2,screen height/2). 
                                Font="${cfg.astronaut.font.name}";
                                FontSize="${cfg.astronaut.font.size}";
                                # Default is screen height divided by 80 (1080/80=13.5), Options: 0-inf.
                                KeyboardSize="0.4";
                                #  Default 0.4, Options 0.1-1.0
                                RoundCorners="20";
                                Locale="";
                                # Locale for data and time format. I suggest leaving it blank.
                                HourFormat=cfg.astronaut.format.time;
                                DateFormat=cfg.astronaut.format.date;

                                HeaderText="";

                            #################### Background ####################

                                BackgroundPlaceholder="";
                                Background="${cfg.astronaut.background}";
                                # Must be a relative path.
                                # Supports: png, jpg, jpeg, webp, gif, avi, mp4, mov, mkv, m4v, webm.
                                BackgroundSpeed="";
                                # Default 1.0. Options: 0.0-10.0 (can go higher).
                                # Speed of animated wallpaper.
                                # Connected with: Background.
                                PauseBackground="";
                                # Default false.
                                # If set to true, stops playback of gifs. Works only with gifs.
                                # Connected with: Background.
                                DimBackground="0.0";
                                # Options: 0.0-1.0.
                                # Connected with: DimBackgroundColor
                                CropBackground="true";
                                # Default false.
                                # Crop or fit background.
                                # Connected with: BackgroundHorizontalAlignment and BackgroundVerticalAlignment dosn't work when set to true.
                                BackgroundHorizontalAlignment="center";
                                # Default: center, Options: left, center, right.
                                # Horizontal position of the background picture.
                                # Connected with: CropBackground must be set to false.
                                BackgroundVerticalAlignment="center";
                                # Horizontal position of the background picture.
                                # Default: center, Options: bottom, center, top.
                                # Connected with: CropBackground must be set to false.

                            #################### Colors ####################

                                HeaderTextColor="#ffffff";
                                DateTextColor="#ffffff";
                                TimeTextColor="#ffffff";

                                FormBackgroundColor="#21222C";
                                BackgroundColor="#21222C";
                                DimBackgroundColor="#21222C";

                                LoginFieldBackgroundColor="#cccccc";
                                PasswordFieldBackgroundColor="#cccccc";
                                LoginFieldTextColor="#ffffff";
                                PasswordFieldTextColor="#ffffff";
                                UserIconColor="#3d495b";
                                PasswordIconColor="#3d495b";

                                PlaceholderTextColor="#ffffff";
                                WarningColor="#3d495b";

                                LoginButtonTextColor="#ffffff";
                                LoginButtonBackgroundColor="#3d495b";
                                SystemButtonsIconsColor="#3d495b";
                                SessionButtonTextColor="#ffffff";
                                VirtualKeyboardButtonTextColor="#ffffff";

                                DropdownTextColor="#ffffff";
                                DropdownSelectedBackgroundColor="#697f90";
                                DropdownBackgroundColor="#3d495b";

                                HighlightTextColor="#bbbbbb";
                                HighlightBackgroundColor="#3d495b";
                                HighlightBorderColor="transparent";

                                HoverUserIconColor="#697f90";
                                HoverPasswordIconColor="#697f90";
                                HoverSystemButtonsIconsColor="#697f90";
                                HoverSessionButtonTextColor="#ffffff";
                                HoverVirtualKeyboardButtonTextColor="#ffffff";

                            #################### Form ####################

                                PartialBlur="";
                                # Default false.
                                FullBlur="";
                                # Default false.
                                # If you use FullBlur I recommend setting BlurMax to 64 and Blur to 1.0.
                                BlurMax="";
                                # Default 48, Options: 2-64 (can go higher because depends on Blur).
                                # Connected with: Blur.
                                Blur="";
                                # Default 2.0, Options: 0.0-3.0 (without 3.0).
                                # Connected with: BlurMax.

                                HaveFormBackground=cfg.astronaut.form.background.enable;
                                # Form background is transparent if set to false.
                                # Connected with: PartialBlur and BackgroundColor.
                                FormPosition=cfg.astronaut.form.position;
                                # Default: left, Options: left, center, right.

                            #################### Virtual Keyboard ####################

                                VirtualKeyboardPosition="left";
                                # Default: left, Options: left, center, right.

                            #################### Interface Behavior ####################

                                HideVirtualKeyboard="false";
                                HideSystemButtons="true";
                                HideLoginButton="true";

                                ForceLastUser="true";
                                # If set to true last successfully logged in user appeares automatically in the username field.
                                PasswordFocus="true";
                                # Automaticaly focuses password field.
                                HideCompletePassword="true";
                                # Hides the password while typing.
                                AllowEmptyPassword="true";
                                # Enable login for users without a password.
                                AllowUppercaseLettersInUsernames="false";
                                # Do not change this! Uppercase letters are generally not allowed in usernames. This option is only for systems that differ from this standard!
                                BypassSystemButtonsChecks="false";
                                # Skips checking if sddm can perform shutdown, restart, suspend or hibernate, always displays all system buttons.
                                RightToLeftLayout="false";
                                # Revert the layout either because you would like the login to be on the right hand side or SDDM won't respect your language locale for some reason. This will reverse the current position of FormPosition if it is either left or right and in addition position some smaller elements on the right hand side of the form itself (also when FormPosition is set to center).
                        };
                    })
                    #pkgs.libsForQt5.qt5.qtmultimedia
                ];
            })
            (lib.mkIf (cfg.catppuccin.enable == true) {
                systemPackages = [
                    (pkgs.catppuccin-sddm.override {
                        flavor = "${cfg.catppuccin.flavor}";
                        font  = "${cfg.catppuccin.font.name}";
                        fontSize = "${cfg.catppuccin.font.size}";
                        background = "${cfg.catppuccin.background}";
                        loginBackground = (if (cfg.catppuccin.background == "") then true else false);
                    })
                ];
            })
        ];
        services = {
            displayManager.sddm = lib.mkMerge[ 
                {
                    enable = lib.mkDefault cfg.enable;
                    wayland.enable = true;
                } 
                (lib.mkIf (cfg.astronaut.enable == true) {
                    theme = "sddm-astronaut-theme"; # Set SDDM theme to sddm-astronaut
                    extraPackages = with pkgs; [
                        pkgs.sddm-astronaut
                    ];
                })
                (lib.mkIf (cfg.catppuccin.enable == true) {
                    theme = lib.mkDefault "catppuccin-${cfg.catppuccin.flavor}"; # Set SDDM theme to sddm-astronaut
                    extraPackages = with pkgs; [
                        pkgs.catppuccin-sddm
                    ];
                })
            ];
        };
    };
}