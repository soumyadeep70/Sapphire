# --- flake-parts/dev-tooling/devShell.nix
{ lib, ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default =
        let
          treefmt-wrapper = if (lib.hasAttr "treefmt" config) then config.treefmt.build.wrapper else null;
          pre-commit = if (lib.hasAttr "pre-commit" config) then config.pre-commit else null;

          env = {
            HOME = "$(mktemp -d)";
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_CACHE_HOME = "$HOME/.cache";
            XDG_DATA_HOME = "$HOME/.local/share";
            XDG_STATE_HOME = "$HOME/.local/state";
          };

          scripts = [
            (pkgs.writeShellScriptBin "rename-project" ''
              set -euo pipefail
              find $1 \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s/Sapphire/$2/g"
            '')
            (pkgs.writeShellScriptBin "show-help" ''
              Y=$'\033[93m'
              W=$'\033[97m'
              C=$'\033[96m'
              RT=$'\033[0m'

              echo "$C╔══════════════════════════════════════════════════════════╗$RT"
              echo "$C║                      📋 Quick Commands                   ║$RT"
              echo "$C╠══════════════════════════════════════════════════════════╣$RT"
              echo "$C║ $Y ● rename-project     $W Rename the whole project          $C║$RT"
              ${lib.optionalString (treefmt-wrapper != null) ''
                echo "$C║ $Y ● fmt                $W Format all files                  $C║$RT"
              ''}
              echo "$C║ $Y ● show-help          $W Display this help message         $C║$RT"
              echo "$C╚══════════════════════════════════════════════════════════╝$RT"
            '')
          ]
          ++ (lib.optional (treefmt-wrapper != null) (
            pkgs.writeShellScriptBin "fmt" ''
              set -e
              exec ${treefmt-wrapper}/bin/treefmt "$@"
            ''
          ));
        in
        pkgs.mkShell {
          packages =
            scripts
            ++ (with pkgs; [
              git
              cz-cli
              vim
              openssh
              nixd
              nix-output-monitor
            ]);

          shellHook = ''
            R=$'\033[91m'
            G=$'\033[92m'
            Y=$'\033[93m'
            RT=$'\033[0m'

            run_command() {
              local rc
              if [ "''${DEBUG:-0}" = "1" ]; then
                "$@" > >(sed "s/^/$Y→$RT /" >&2) 2>&1
                rc=''${PIPESTATUS[0]}
              else
                "$@" >/dev/null 2>&1
                rc=$?
              fi
              return $rc
            }

            eval "$(${pkgs.starship}/bin/starship init bash)"
            ${lib.concatLines (lib.mapAttrsToList (name: value: "export ${name}=${value}") env)}
            mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"

            ${lib.optionalString (pre-commit != null) ''
              setup_pre_commit() {
                success() {
                  echo "$G✓$RT Pre-commit installed successfully." >&2
                }
                failure() {
                  echo "$R✗$RT Pre commit installation failed." >&2
                }
                run_command ${pkgs.writeShellScript "pre-commit-script" pre-commit.installationScript} \
                  || { failure; return 1; }
                success
              }
              setup_pre_commit
            ''}

            setup_github_ssh_auth() {
              success() {
                echo "$G✓$RT SSH setup completed successfully." >&2
              }
              failure() {
                echo "$R✗$RT SSH setup failed: $1" >&2
              }
              run_command mkdir -p "$HOME/.ssh" || { failure "failed to create .ssh directory"; return 1; }
              run_command touch "$HOME/.ssh/known_hosts" || { failure "failed to create known_hosts file"; return 1; }
              run_command ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null \
                || { failure "failed to fetch and write github.com host key"; return 1; }
              run_command eval "$(ssh-agent -s)" || { failure "error starting ssh-agent"; return 1; }
              run_command ${pkgs.dotenv-cli}/bin/dotenv -f .env -- sh -c '
                git config --global user.name "$GITHUB_USERNAME"
                git config --global user.email "$GITHUB_USEREMAIL"
              ' || { failure "failed to set git username and email"; return 1; }
              run_command ${pkgs.dotenv-cli}/bin/dotenv -f .env -- sh -c '
                printf "%s\n" "$GITHUB_AUTH_PRIVATE_KEY" | ssh-add -
              ' || { failure "failed to add private key to ssh-agent"; return 1; }
              success
            }
            setup_github_ssh_auth

            cleanup() {
              eval "$(ssh-agent -k)" 2>&1 || true
              rm -rf "$HOME"
            }
            trap cleanup EXIT
          '';
        };
    };
}
