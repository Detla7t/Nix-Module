{
    lib,
    pkgs,
    ...
}: {
    options = {
        enable = lib.mkEnableOption "audio";
        packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
                # Audio Programs
                    # alsa-utils # Advanced Linux Sound Architecture utils
                    # ardour # A professional digital audio workstation
                    audacity # Sound editor and Recorder
                    # lsp-plugins # Collection of open-source audio plugins
                    # sonobus # Network Audio Streamer
                    qpwgraph # Pipewire Patchbay
                    reaper # A professional digital audio workstation
                    # yabridge # A transparent way to use Windows VST2 and VST3 plugins on Linux
            ];
            description = ''
            Enables Audio related features.
            '';
        };
    };
}