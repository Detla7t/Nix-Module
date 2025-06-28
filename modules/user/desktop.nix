{
    lib,
    pkgs,
    ...
}: {
    options = {
        #enable = lib.mkEnableOption "desktop";
        wallpaper = lib.mkOption {
            default = "";
            type = lib.types.either lib.types.path lib.types.str;
        };
        KDE = {
            wallpaper = lib.mkOption {
                default = "";
                type = lib.types.either lib.types.path lib.types.str;
            };
            lockscreen_background = lib.mkOption {
                default = "";
                type = lib.types.either lib.types.path lib.types.str;
            };
        };
        Gnome = {
            wallpaper = lib.mkOption {
                default = "";
                type = lib.types.either lib.types.path lib.types.str;
            };
        };
        Hyprland = {
            wallpaper = lib.mkOption {
                default = "";
                type = lib.types.either lib.types.path lib.types.str;
            };
        };
    };
}