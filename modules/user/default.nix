{ 
    name, 
    lib,
    pkgs,
    config,
    #options, 
    ... 
}: 
    let
        audio_module = (import ./audio.nix {inherit lib; inherit pkgs;});
        file_module = (import ./files.nix {inherit config; inherit lib;});
        gaming_module = (import ./gaming.nix {inherit lib; inherit pkgs;});
        productivity_module = (import ./productivity.nix {inherit lib; inherit pkgs;});
        service_module = (import ./service.nix {inherit name; inherit config; inherit lib;});
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
            #desktop = lib.mkOption {
            #    type = lib.types.submodule {
            #        options = 
            #    }
            #};
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
}