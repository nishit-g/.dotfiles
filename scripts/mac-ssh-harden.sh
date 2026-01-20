#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}▶${NC} $1"; }
success() { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${RED}!${NC} $1"; }

SSHD_CONFIG="/etc/ssh/sshd_config"

echo "SSH Hardening for macOS"
echo "======================="
echo ""
warn "This requires sudo and modifies SSH config"
echo ""

info "Current SSH status:"
sudo systemsetup -getremotelogin || true

echo ""
info "Recommended sshd_config changes:"
cat << 'SSHD'

# Add to /etc/ssh/sshd_config:
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
ChallengeResponseAuthentication no
UsePAM yes
AllowAgentForwarding yes
AllowTcpForwarding yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/libexec/sftp-server

SSHD

echo ""
info "To enable Remote Login (SSH):"
echo "  sudo systemsetup -setremotelogin on"
echo ""
info "To add Termux key to authorized_keys:"
echo "  # On Termux, run:"
echo "  ssh-copy-id user@your-mac-tailscale-ip"
echo ""
info "Or manually add key:"
echo "  # Copy from Termux: cat ~/.ssh/id_ed25519.pub"
echo "  # On Mac: nano ~/.ssh/authorized_keys"
echo "  # Paste the key and save"
echo ""
success "Review complete. Apply changes manually for safety."
