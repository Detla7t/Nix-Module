{
    lib,
    config,
    ...
}: {
    options = {
        enable = lib.mkEnableOption "files";
        homeFolders = {
            enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = ''Enable link home folders from another location.'';
            };
            location = lib.mkOption {
                type = lib.types.str;# || lib.types.path;
                default = "";
                description = ''remote directory you want to user as your /home/<user>/Documents, Downloads, Games, Music, Pictures, Programs, Public, Videos folder.'';
            };
        };
        linkSteam = {
            enable = lib.mkEnableOption "linkSteam";
            location = lib.mkOption {
                type = lib.types.str;# || lib.types.path;
                default = "";
                description = ''location of steam .local folder normally `/home/<user>/.local/share/Steam`'';
            };
        };
        makeFolders = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "this is a list of packages to link should be (package: location:)";
        };
        linkPackage = lib.mkOption {
            type = lib.types.listOf lib.types.anything;
            default = [];
            description = "this is a list of packages to link should be (package: location:)";
        };
        simpleLink = lib.mkOption {
            type = lib.types.listOf lib.types.anything;
            default = [];
            description = "this is a list of packages to link should be (package: location:)";
        };
        simpleCopyFiles = lib.mkOption {
            type = lib.types.listOf lib.types.anything;
            default = [];
            description = "this is a list of packages to link should be (package: location:)";
        };
        copyFolders = lib.mkOption {
            type = lib.types.listOf lib.types.anything;
            default = [];
            description = "this is a list of packages to copy should be (package: location:)";
        };
        copyFiles = lib.mkOption {
            type = lib.types.listOf lib.types.anything;
            default = [];
            description = "this is a list of packages to copy should be (package: location:)";
        };
    };
}