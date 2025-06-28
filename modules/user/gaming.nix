{
    lib,
    pkgs,
    ...
}: {
    options = {
        enable = lib.mkEnableOption "gaming";
        packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
                mangohud # An overlay for monitoring FPS, temperatures, CPU/GPU
                unstable.openrct2
                openvr
                openxr-loader
                protontricks # Simple Proton Wrapper
                protonup-ng # CLI program and API for ProtonGE
                protonup-qt # Proton Installer Gui
                prismlauncher # Minecraft Launcher
                unstable.r2modman # Unofficial Thunderstore mod manager
                scanmem # Memory Scaner and editor
                shipwright # PC port of Ocarina of Time
                vesktop # Vencord client for discord an instant messaging and VoIP social platform
                #wlx-overlay-s # Wayland/X11 desktop overlay for SteamVR and OpenXR
                xclicker # Simple and good autoclicker
            ];
            description = ''
            Enables gaming related features.
            '';
        };
        emulator.enable = lib.mkEnableOption "emulator";
        emulator.packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
                flycast # Sega Dreamcast, Naomi and Atomiswave emulator
                dolphin-emu # Emulator for Gamecube/Wii/Triforce 
                heroic # Epic games and Gog Launcher
                mupen64plus # Nintendo 64 Emulator
                melonDS # Nintendo DS emulator
                mgba # GBA emulator
                sameboy # Game Boy, Game Boy Color, and Super Game Boy emulator
                snes9x # Snes Emulator
                duckstation # Playstation 1 Emulator
                pcsx2 # Playstation 2 Emulator
                rpcs3 # Playstation 3 Emulator
                xemu # Emulator for Original Xbox 
                ppsspp # Playstation portable Emulator
                #ppsspp-sdl-wayland
                scummvm # An emulator to run certain classic graphical point-and-click adventure games
            ];
            description = ''
            Adds eumlator related packages.
            '';
        };
        vr.enable = lib.mkEnableOption "vr";
        vr.packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
                alvr # VR Input,Video, and Audio Streamer
            ];
            description = ''
            Enables vr gaming related features.
            '';
        };
    };
}