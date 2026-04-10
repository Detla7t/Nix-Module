# Experimental system patches and workarounds
# These address upstream bugs and hardware-specific issues
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.essence.patches;
in {
  options.essence.patches = {
    enable = lib.mkEnableOption "experimental system patches and workarounds";

    amdIommu = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Fix for "AMD-Vi: Completion-Wait loop timed out" errors.
          Adds kernel parameter to increase IOMMU timeout or use soft mode.
        '';
      };
      mode = lib.mkOption {
        type = lib.types.enum ["timeout" "soft" "off"];
        default = "timeout";
        description = ''
          - timeout: Increase IOMMU completion wait timeout
          - soft: Use software IOMMU (less performance but more stable)
          - off: Disable IOMMU entirely (not recommended, breaks VFIO)
        '';
      };
    };

    btopNvidia = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Fix for btop SIGABRT crashes when monitoring NVIDIA GPUs.
          Wraps btop to handle libnvidia-ml race conditions.
        '';
      };
    };

    electronWayland = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Improve Electron app stability on NVIDIA + Wayland.
          Sets additional environment variables for better compatibility.
        '';
      };
    };

    sambaNetbios = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Reduce nmbd WORKGROUP master browser election conflicts.
          Sets this machine to not compete for master browser role.
        '';
      };
    };

    nvidiaWayland = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          NVIDIA + Wayland critical environment variables.
          Fixes EGL context creation failures and framebuffer issues.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # AMD IOMMU fix
    (lib.mkIf cfg.amdIommu.enable {
      boot.kernelParams =
        lib.optionals (cfg.amdIommu.mode == "timeout") [
          "amd_iommu=on"
          "iommu=pt" # passthrough mode - better performance
        ]
        ++ lib.optionals (cfg.amdIommu.mode == "soft") [
          "iommu=soft"
        ]
        ++ lib.optionals (cfg.amdIommu.mode == "off") [
          "iommu=off"
          "amd_iommu=off"
        ];
    })

    # btop NVIDIA fix - create a wrapper that handles crashes gracefully
    (lib.mkIf cfg.btopNvidia.enable {
      environment.systemPackages = [
        # Wrapper to handle btop crashes from libnvidia-ml race conditions
        (pkgs.writeShellScriptBin "btop" ''
          # Disable GPU monitoring if crashes persist by setting BTOP_GPU_DISABLE=1
          export BTOP_GPU_DISABLE=''${BTOP_GPU_DISABLE:-0}

          # Run btop with trap to catch SIGABRT
          trap 'echo "btop crashed - try running with BTOP_GPU_DISABLE=1"' ABRT
          exec ${pkgs.btop}/bin/btop "$@"
        '')
        # Also provide the original btop as btop-unwrapped
        (pkgs.runCommand "btop-unwrapped" {} ''
          mkdir -p $out/bin
          ln -s ${pkgs.btop}/bin/btop $out/bin/btop-unwrapped
        '')
      ];
    })

    # Electron + Wayland + NVIDIA stability
    (lib.mkIf cfg.electronWayland.enable {
      environment.sessionVariables = {
        # Force Electron apps to use Wayland
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        # Disable GPU compositing if it causes issues (fallback)
        # LIBGL_ALWAYS_SOFTWARE = "1"; # Uncomment if GPU compositing crashes
      };
      environment.variables = {
        # Additional flags for Chromium/Electron
        NIXOS_OZONE_WL = "1";
      };
    })

    # Samba NetBIOS master browser fix
    (lib.mkIf cfg.sambaNetbios.enable {
      services.samba.settings.global = lib.mkIf config.services.samba.enable {
        # Don't compete for master browser - reduces WORKGROUP conflicts
        "local master" = "no";
        "preferred master" = "no";
        "domain master" = "no";
        "os level" = "0";
      };
    })

    # NVIDIA + Wayland environment variables
    (lib.mkIf cfg.nvidiaWayland.enable {
      environment.variables = {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
        # KDE Plasma Wayland specific - prevents EGL context creation failures
        KWIN_DRM_NO_AMS = "1";
        NIXOS_OZONE_WL = "1";
      };
      environment.sessionVariables = {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    })
  ]);
}
