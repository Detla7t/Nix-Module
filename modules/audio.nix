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
            audioSettings = {
                enable = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = ''
                        Enable the settings required to setup audio
                    '';
                };
                fixMemory = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = ''
                        Enable the settings required to setup audio
                    '';
                };
            };
        };
    };

    config = 
    let 
        cfg = config.essence.audioSettings;
        loopback_builder = NAME: {
            factory = "adapter";
            args = {
                "factory.name"     = "support.null-audio-sink";
                "node.description" = "${NAME}";
                "node.name"        = "input.${NAME}";
                "node.passive" = true;
                "media.class"      = "Audio/Sink";
                "audio.position"   = "FL,FR";
                "priority.driver"  = 8000;
            };
        };
        # disable_node = DESCRIPTION: {
        #     monitor.alsa.rules = [
        #         {
        #         matches = [ {
        #             "device.description" = "${DESCRIPTION}";
        #         } ];
        #         actions = {
        #             update-props = {
        #                 "node.disabled" = true;
        #             };
        #         };
        #         }
        #     ];
        # };
    in
    {
        security = (lib.mkIf (cfg.fixMemory == true) {
            pam.loginLimits = [
                { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
                { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
                { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
                { domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }
            ];
            rtkit.enable = true;
        });
        services.pulseaudio.enable = false;
        services.pipewire = (lib.mkIf (cfg.enable == true) {
            enable = true;
            extraConfig.pipewire."91-null-sinks" = { #(lib.mkIf (cfg.enableSinks == true) {
            #     "context.objects" = [
            #         (loopback_builder "firefox-loopback")
            #         (loopback_builder "discord-loopback")
            #         (loopback_builder "music-loopback")
            #         (loopback_builder "game-loopback")
            #         (loopback_builder "video-player-loopback")
            #         {
            #             factory = "adapter";
            #             args = {
            #                 "factory.name"     = "support.null-audio-sink";
            #                 #Node Properties
            #                 "node.autoconnect" = true;
            #                 "node.description" = "Main-out-loopback";
            #                 "node.name"        = "input.Main-out-loopback";
            #                 "node.target" = "SSL-2";
            #                 "media.class"      = "Audio/Sink";
            #                 "audio.position"   = "FL,FR";
            #                 "priority.driver"  = 9000;
            #             };
            #         }
            #         {
            #             factory = "adapter";
            #             args = {
            #                 "factory.name"     = "support.null-audio-sink";
            #                 "node.name"        = "output.microphone-loopback";
            #                 "node.description" = "microphone-loopback";
            #                 "media.class"      = "Audio/Duplex";
            #                 "audio.position"   = "FL,FR";
            #                 "priority.driver"  = 8000;
            #             };
            #         }
            #     ];
                "context.properties" = {
                    default.clock.rate = 48000;
                    default.clock.quantum = 256;
                    default.clock.min-quantum = 32;
                    default.clock.max-quantum = 256;
                };
            };
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;

            # wireplumber = {
            #     extraConfig = (lib.mkIf (cfg.enableSinks == true) {
            #         "SSL-2" = {
            #             monitor.alsa.rules = [
            #                 {
            #                 matches = [ {
            #                     "device.name" = "alsa_card.usb-Solid_State_Logic_SSL_2-00";
            #                     "device.serial" = "Solid_State_Logic_SSL_2";
            #                     "device.vendor.name" = "Solid State Logic";
            #                 } ];
            #                 actions = {
            #                     update-props = {
            #                         "node.nick" = "SSL-2";
            #                     };
            #                 };
            #                 }
            #             ];
            #         };
            #         "Disable-gpu-1" = disable_node "GA102 High Definition Audio Controller";
            #         "Disable-gpu-2" = disable_node "Rembrandt Radeon High Definition Audio Controller";
            #         "Disable-onboard" = disable_node "Family 17h/19h/1ah HD Audio Controller"; 
            #     });
            # };
        });
    };
}