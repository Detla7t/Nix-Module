{
    lib,
    pkgs,
    ...
}: {
    options = {
        administration.enable = lib.mkEnableOption "administration";
        administration.packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
                # File Transfer and Management
                    filezilla # FTP, FTPS and SFTP Client
                    qdirstat # Disk Storage Usage Visualizer

                # Remote management
                    barrier # Keyboard and mouse sharing utility. TODO: Be sure to check untill your able to make a valid config for input-leap
                    #input-leap # Barrier Replacement Keyboard and mouse sharing utility.
                    remmina # RDP/VNC Client
            ];
            description = ''
            Enables System Admin related features.
            '';
        };
        development.enable = lib.mkEnableOption "development";
        development.packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
                # AI tools
                    lmstudio # Local LLM Downloader/Loader version controlled by me

                # Container Management
                    # boxbuddy # An unofficial GUI for managing your Distroboxes
                    # distrobox # Run different Linux distros via containers
                    # virt-viewer # virtmanager viewer gui?

                # Libraries
                    # conda  # A package manager for Python
                    cudatoolkit # CUDA Library for GPU computation

                # Editors
                    micro # terminal based text editor
                    nixfmt-rfc-style # official Nix formatter with a standardized formatting
                    nixd # Nix language server
                    unstable.obsidian # Markdown editor
                    (vscode-with-extensions.override { # Visual Studio Code but with extensions Text editor/IDE
                        vscodeExtensions = [
                            vscode-extensions.vscjava.vscode-gradle
                            vscode-extensions.vscjava.vscode-java-pack
                            vscode-extensions.vscjava.vscode-maven
                            vscode-extensions.redhat.java
                            vscode-extensions.bbenoist.nix # vscode plugin to add nix syntax
                            unstable.vscode-extensions.egirlcatnip.adwaita-github-theme
                            #vscode-extensions.equinusocio.vsc-material-theme-icons
                            #vscode-extensions.hiukky.flate
                            vscode-extensions.jnoortheen.nix-ide # vscode plugi for Nix language support with formatting and error report
                            # vscode-extensions.jdinhlife.gruvbox # vscode gruvbox theme
                            #vscode-extensions.ms-vscode.theme-tomorrowkit
                            vscode-extensions.pkief.material-icon-theme
                            unstable.vscode-extensions.platformio.platformio-vscode-ide
                            # vscode-extensions.teabyii.ayu
                            vscode-extensions.viktorqvarfordt.vscode-pitch-black-theme
                            vscode-extensions.vscodevim.vim # vscode plugin for vim bindings
                        ];
                    })
                # USB Flasher
                    #ventoy-full
                    impression # Gnome USB Flash Utility
                    #isoimagewriter # KDE USB Flash Utility
                    #mediawriter # Fedora's USB Media Flash Utility
                    #popsicle
                git # source repository file controller/manager
            ];
            description = ''
            Adds development related packages.
            '';
        };
        office.enable = lib.mkEnableOption "office";
        office.packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
                # Calculators
                    parsify # Notepad calculator
                    qalculate-qt # Scientific calculator
                    gnome-calculator # Generic calculator

                # Graphics and Design
                    inkscape # vector graphics editor
                    krita # Image Editor
                    prusa-slicer # 3d Printer Slicer
                    # sweethome3d.application # Design and visualize floor planner
                    # sweethome3d.furniture-editor
                    # sweethome3d.textures-editor

                    libreoffice # Office Suite
            ];
            description = ''
            Enables Office and work related features.
            '';
        };
    };
}