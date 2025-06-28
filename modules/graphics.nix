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
            graphicsSettings = {
                amd.enable = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = ''
                        Enable the settings required to setup AMD GPUs
                    '';
                };
                nvidia.enable = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = ''
                        Enable the settings required to setup AMD GPUs
                    '';
                };
            };
        };
    };

    config = {
        environment= {
            variables = lib.mkIf (config.essence.graphicsSettings.nvidia.enable == true) {
                CUDA_PATH = "${pkgs.cudatoolkit}";
                CUDA_TOOLKIT_ROOT_DIR = "${pkgs.cudatoolkit}";
            };
        };

        #hardware.graphics.enable32Bit = true; Haven't ever tested

        # Load nvidia driver for Xorg and Wayland
        services.xserver.videoDrivers =  [] 
            ++ (if (config.essence.graphicsSettings.amd.enable == true) then [ "amdgpu" ] else [] )
            ++ (if (config.essence.graphicsSettings.nvidia.enable == true) then [ "nvidia" ] else [] )
        ;
        hardware.nvidia = (lib.mkIf (config.essence.graphicsSettings.nvidia.enable == true){
            open = false;
            # Enable the Nvidia settings menu,
            # accessible via `nvidia-settings`.
            nvidiaSettings = false;
            # Optionally, you may need to select the appropriate driver version for your specific GPU.
            #Disabled To fix Flicker is certain programs like steam, and minecraft caused by sync issue usually my gpu making too many frames temp fix was to lower power level to limit gpu performance
            package = config.boot.kernelPackages.nvidiaPackages.stable;
            videoAcceleration = false; #Attempt to fix in zen `WARNING: Decoder=7fabdf6eb100 Decode error: NS_ERROR_DOM_MEDIA_FATAL_ERR`
        });
        hardware.nvidia-container-toolkit.enable = config.essence.graphicsSettings.nvidia.enable;
    };
}