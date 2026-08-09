#!/usr/bin/env bash
set -e

echo "Installing git, direnv via apt..."
sudo apt-get update
sudo apt-get install -y git direnv

echo "Installing nix-direnv via Nix profile..."
nix profile add nixpkgs#{nix-direnv,nixd}

echo "Configuring nix-direnv integration..."
mkdir -p ~/.config/direnv
cat << 'EOF' > ~/.config/direnv/direnvrc
source ~/.nix-profile/share/nix-direnv/direnvrc
EOF

echo "Hooking direnv into bash..."
if ! grep -q 'direnv hook bash' ~/.bashrc; then
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
fi

echo "Applying silent direnv config..."
cat << 'EOF' > ~/.config/direnv/direnv.toml
[global]
log_format = "-"
log_filter = "^$"
EOF

echo "Automatically allowing direnv..."
direnv allow

echo "Setup complete!"