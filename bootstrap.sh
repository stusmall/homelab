#!/usr/bin/env bash
set -euo pipefail
if [ "$(id -u)" -ne 0 ]
  then echo "Please run as root"
  exit
fi
echo "Running the initial set up of the system..."
REPO_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null &&  pwd )
echo "Setting symlink to point to $REPO_ROOT"
rm -f /etc/nixos/configuration.nix || true
rm -f /etc/nixos/hardware-configuration.nix || true
ln -s "$REPO_ROOT"/node-1.nix /etc/nixos/configuration.nix
nixos-rebuild switch || true
echo "Please input a dreamhost API key:"
read -r line
mkdir /var/lib/acme_secret/
chown acme:acme /var/lib/acme_secret/
echo "DREAMHOST_API_KEY=$line" > /var/lib/acme_secret/dreamhost_env
chown acme:acme /var/lib/acme_secret/dreamhost_env
chmod -R 400 /var/lib/acme_secret
echo "API key successfully written"
