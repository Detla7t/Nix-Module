{
    # Import all your configuration modules here
    imports = [ ./bufferline.nix ];
    colorschemes = {
        base16 = {
            enable = false;
            colorscheme = {
                base00 = "#000000";
                base01 = "#303030";
                base02 = "#505050";
                base03 = "#b0b0b0";
                base04 = "#d0d0d0";
                base05 = "#e0e0e0";
                base06 = "#f5f5f5";
                base07 = "#ffffff";
                base08 = "#fb0120";
                base09 = "#fc6d24";
                base0A = "#fda331";
                base0B = "#a1c659";
                base0C = "#76c7b7";
                base0D = "#6fb3d2";
                base0E = "#d381c3";
                base0F = "#be643c";
            };
        };
    };

    plugins = {
        barbar.enable = true;
        dashboard = {
            enable = true;
            settings = {
                config = {
                    footer = [
                        "Made with 󰋑"
                    ];
                    header = [
                        ""
                        "███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗"
                        "████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║"
                        "██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║"
                        "██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║"
                        "██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║"
                        "╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝"
                        ""
                    ];
                    shortcut = [
                        {
                            action = {
                                __raw = "function(path) vim.cmd('Telescope find_files') end";
                            };
                            desc = "Files";
                            group = "Label";
                            icon = "  ";
                            icon_hl = "@variable";
                            key = "f";
                        }
                        {
                            action = "Telescope app";
                            desc = " Apps";
                            icon = " ";
                            group = "DiagnosticHint";
                            key = "a";
                        }
                        {
                            action = "Telescope dotfiles";
                            desc = " dotfiles";
                            group = "Number";
                            icon = "";
                            key = "d";
                        }
                    ];
                };
            };
        };
        lazygit.enable = true;
        lsp = {
            enable = true;
            servers = {
                nixd.enable = true;
            };
        };
        lualine.enable = true; # Adds Bottom Bar?
        nix.enable = true;
        neo-tree.enable = true;
        # Popular plugins
            telescope.enable = true;
            oil.enable = true;
            treesitter.enable = true;
            luasnip.enable = true;
    };
}
