# --- flake-parts/dev-tooling/devShell.nix
{ lib, ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default =
        let
          treefmt-wrapper = if (lib.hasAttr "treefmt" config) then config.treefmt.build.wrapper else null;
          pre-commit-script =
            if (lib.hasAttr "pre-commit" config) then config.pre-commit.installationScript else null;
          scripts = import ./scripts { inherit lib pkgs; };
        in
        pkgs.mkShell {
          packages =
            builtins.attrValues scripts
            ++ [
              pkgs.pre-commit
              pkgs.openssh
              pkgs.nixd
              pkgs.nix-output-monitor
            ]
            ++ lib.optional (treefmt-wrapper != null) treefmt-wrapper;

          shellHook = ''
            help() {
              ${scripts.help}/bin/help
            }

            report_status() {
              local level="$1"; shift
              case "$level" in
                success)
                  printf '{{ Foreground "#00FF00" "✓ %s" }}' "$*" ;;
                failure)
                  printf '{{ Foreground "#FF0000" "✗ %s" }}' "$*" ;;
                *)
                  printf '%s' "$*" ;;
              esac | ${pkgs.gum}/bin/gum format -t template
              printf '\n'
            }

            start_spinner() {
              ${pkgs.gum}/bin/gum spin --spinner points --title "$1" -- sleep infinity &
              spinner_pid=$!
            }

            stop_spinner() {
              kill "$1" 2>/dev/null || true
              wait "$1" 2>/dev/null || true
            }

            PROJECT_ROOT="$(git rev-parse --show-toplevel)"
            export HOME="$PROJECT_ROOT/.devshell-home";
            export XDG_CONFIG_HOME="$HOME/.config";
            export XDG_CACHE_HOME="$HOME/.cache";
            export XDG_DATA_HOME="$HOME/.local/share";
            export XDG_STATE_HOME="$HOME/.local/state";

            rm -rf "$HOME"
            mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"
            eval "$(${pkgs.starship}/bin/starship init bash)"

            log_file="$HOME/shell-setup.log"

            ${lib.optionalString (pre-commit-script != null) ''
              install_pre_commit() {
                ${pre-commit-script}
              }
              start_spinner "Installing pre-commit hooks..."
              printf "[Pre-commit installation]\n" >>"$log_file"
              install_pre_commit >>"$log_file" 2>&1
              status=$?
              stop_spinner "$spinner_pid"
              if [ "$status" = "0" ]; then
                report_status success "Pre-commit installed successfully."
              else
                report_status failure "Pre-commit installation failed."
              fi
            ''}

            git_ssh_setup() {
              mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh" \
                || { echo "Error: failed to create .ssh directory"; return 1; }
              touch "$HOME/.ssh/known_hosts" && chmod 600 "$HOME/.ssh/known_hosts" \
                || { echo "Error: failed to create known_hosts file"; return 1; }
              ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null \
                || { echo "Error: failed to fetch github.com host key"; return 1; }
              eval "$(ssh-agent -s)" \
                || { echo "Error: ssh-agent initialization failed"; return 1; }
              ${pkgs.dotenv-cli}/bin/dotenv -f .env -- sh -c '
                set -e
                git config --global user.name "$GITHUB_USERNAME"
                git config --global user.email "$GITHUB_USEREMAIL"
              ' || { echo "Error: failed to set git username and email"; return 1; }
              ${pkgs.dotenv-cli}/bin/dotenv -f .env -- sh -c '
                set -e
                if [ -f "$GITHUB_AUTH_PRIVATE_KEY" ]; then
                  ssh-add "$GITHUB_AUTH_PRIVATE_KEY"
                else
                  printf '%s\n' "$GITHUB_AUTH_PRIVATE_KEY" | ssh-add -
                fi
              ' || { echo "Error: failed to add private key to ssh-agent"; return 1; }
            }
            start_spinner "Setting up Git and SSH..."
            printf "\n[Git + SSH setup]\n" >>"$log_file"
            git_ssh_setup >>"$log_file" 2>&1
            status=$?
            stop_spinner "$spinner_pid"
            if [ "$status" = "0" ]; then
              report_status success "Git and SSH setup completed successfully."
            else
              report_status failure "Git and SSH setup failed."
            fi

            cleanup() {
              eval "$(ssh-agent -k)" >/dev/null 2>&1 || true
              rm -rf "$HOME"
            }
            trap cleanup EXIT
          '';
        };
    };
}
