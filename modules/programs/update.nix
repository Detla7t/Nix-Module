{
  config,
  lib,
  pkgs,
  ...
}: let
  #Update_script = pkgs.writeShellScriptBin "updater" ''
  Update_script = pkgs.writeShellApplication {
    name = "update";
    runtimeInputs = with pkgs; [
        git
        nh
    ];
    text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    FLAKE_DIR="${config.programs.nh.flake}"

    usage() {
        cat <<EOF
    Usage: update [all|flake|flatpak|upgrade|help]

    Note: If your trying to update and upgrade run "update upgrade" then "update all"

    Commands:
    help        Show this message
    all         Update flatpaks then the flake (flake run includes git checks, dry-run, optional push, real build)
    flatpak     Run 'flatpak update' only. No git changes.
    flake       Run flake update: verify git clean, dry-run build, optional push, real build.
    upgrade     Run 'nix flake update' in the repo root, commit flake.lock with default message and optionally push.
    EOF
    }

    # Capture passthrough args (anything after the subcommand)
    PASSTHRU_ARGS=()
    if [ "$#" -ge 2 ]; then
        # shellcheck disable=SC2086
        PASSTHRU_ARGS=("''${@:2}")
        if [ "''${PASSTHRU_ARGS[0]:-}" = "--" ]; then
            PASSTHRU_ARGS=("''${PASSTHRU_ARGS[@]:1}")
        fi
    fi

    ask_push_default_yes() {
        local ans
        read -r -p "Push local commits to remote? [Y/n] " ans || ans=Y
        ans=''${ans:-Y}
        case "$ans" in
            [Nn]*) return 1 ;;
            *) return 0 ;;
        esac
    }

    update_flatpak() {
        echo "==> Running flatpak update"
        if ! command -v flatpak >/dev/null 2>&1; then
            echo "flatpak not found on PATH"
            return 1
        fi
        if ! flatpak update; then
            echo "flatpak update failed"
            return 1
        fi
        echo "flatpak update complete"
        return 0
    }

    # Helper to run nh with optional extra args or FLAKE_MAX_JOBS
    _run_nh() {
        # args are the fixed nh arguments before the -- separator (e.g. "os switch -H \"$(hostname)\" -n")
        # this function appends -- followed by either PASSTHRU_ARGS (if provided) or -j FLAKE_MAX_JOBS (if set).
        local base_cmd=("$@")
        local nh_args=()
        if [ "''${#PASSTHRU_ARGS[@]}" -gt 0 ]; then
            nh_args=("''${PASSTHRU_ARGS[@]}")
        elif [ -n "$FLAKE_MAX_JOBS" ]; then
            nh_args=("-j" "$FLAKE_MAX_JOBS")
        fi

        if [ "''${#nh_args[@]}" -gt 0 ]; then
            "''${base_cmd[@]}" -- "''${nh_args[@]}"
        else
            "''${base_cmd[@]}"
        fi
    }

    update_flake() {
        echo "==> Running flake update at: $FLAKE_DIR"
        if [ ! -d "$FLAKE_DIR" ]; then
            echo "Flake path does not exist: $FLAKE_DIR"
            return 1
        fi

        cd "$FLAKE_DIR" || return 1

        # Check for uncommitted changes
        if [ -n "$(git status --porcelain)" ]; then
            echo "Flake path is dirty! Please commit changes before continuing."
            git status --short
            return 1
        fi

        branch=$(git rev-parse --abbrev-ref HEAD)
        upstream_exists=0
        if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
            upstream_exists=1
            unpushed=$(git rev-list --count '@{u}'..HEAD)
        else
            upstream_exists=0
            # No upstream configured. Treat any commits as unpushed.
            unpushed=$(git rev-list --count HEAD)
        fi

        push_yes=0
        if [ "$unpushed" -gt 0 ]; then
            echo "Local branch '$branch' has $unpushed unpushed commit(s)."
            if ask_push_default_yes; then
                push_yes=1
            else
                push_yes=0
            fi
        fi

        echo "Running dry-run to check for errors"
        # Use helper to include extra nh args or FLAKE_MAX_JOBS
        if ! _run_nh nh os switch -H "$(hostname)" -n; then
            echo "Dry-run build failed. Aborting without pushing."
            return 1
        fi
        echo "Dry-run build succeeded."

        if [ "$push_yes" -eq 1 ]; then
            echo "Pushing commits to remote..."
            if [ "$upstream_exists" -eq 1 ]; then
                if ! git push; then
                    echo "git push failed"
                    return 1
                fi
            else
                if ! git push --set-upstream origin "$branch"; then
                    echo "git push --set-upstream failed"
                    return 1
                fi
            fi
            echo "Push complete."
        fi

        echo "Running final build to finish update."
        if ! _run_nh nh os switch -H "$(hostname)"; then
            echo "Real build failed."
            return 1
        fi
        echo "Real build succeeded."
        return 0
    }

    upgrade_flake_lock() {
        echo "==> Upgrading flake inputs at: $FLAKE_DIR"
        if [ ! -d "$FLAKE_DIR" ]; then
            echo "Flake path does not exist: $FLAKE_DIR"
            return 1
        fi

        cd "$FLAKE_DIR" || return 1

        # Warn if repository has uncommitted changes
        if [ -n "$(git status --porcelain)" ]; then
            echo "Repository has uncommitted changes:"
            git status --short
            read -r -p "Repository is dirty. Continue with 'nix flake update' anyway? [y/N] " ans || ans=N
            ans=''${ans:-N}
            case "$ans" in
                [Yy]*) ;;
                *) echo "Aborting."; return 1 ;;
            esac
        fi

        echo "Running 'nix flake update'..."
        if ! nix flake update; then
            echo "nix flake update failed"
            return 1
        fi

        # If flake.lock changed or is untracked, commit it
        if [ -n "$(git status --porcelain -- 'flake.lock')" ]; then
            git add flake.lock
            commit_msg="Updated flake.lock inputs."
            if ! git commit -m "$commit_msg"; then
                echo "git commit failed"
                return 1
            fi
            echo "Committed flake.lock with message: $commit_msg"

            # Ask to push (default yes)
            if ask_push_default_yes; then
                branch=$(git rev-parse --abbrev-ref HEAD)
                if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
                    if ! git push; then
                        echo "git push failed"
                        return 1
                    fi
                else
                    if ! git push --set-upstream origin "$branch"; then
                        echo "git push --set-upstream failed"
                        return 1
                    fi
                fi
                echo "Push complete."
            else
                echo "Not pushing commits."
            fi
        else
            echo "flake.lock unchanged; no commit needed."
        fi

        return 0
    }

    case "''${1:-}" in
        ""|help|-h|--help)
            usage
            exit 0
            ;;
        all)
            update_flatpak || exit 1
            update_flake || exit 1
            ;;
        flatpak)
            update_flatpak || exit 1
            ;;
        flake)
            update_flake || exit 1
            ;;
        upgrade)
            upgrade_flake_lock || exit 1
            ;;
        *)
            echo "Unknown subcommand: ''${1:-}"
            usage
            exit 2
            ;;
    esac
    '';
  }; 
in {
  options = {
        # option declarations
        essence = {
            updater = {
                enable = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = ''
                        Enables the system updater that uses Nix Helper as the backend
                    '';
                };
                max-jobs = lib.mkOption {
                    type = lib.types.str;
                    default = "4";
                    description = ''
                        Sets the Max number of jobs used by default when rebuilding using the all or flake update subcommands.
                    '';
                };
            };
        };
    };
  config = let 
        cfg = config.essence.updater;
  in {
        environment = lib.mkIf (cfg.enable == true) {
            systemPackages = [
                Update_script
            ];
            variables = { 
                FLAKE_MAX_JOBS = cfg.max-jobs; 
            };
        };
        programs = lib.mkIf (cfg.enable == true) {
            nh.enable = true;
            #zsh.shellAliases = {
            #    update = "${lib.getExe Update_script}";
            #};
        };
  };
}
