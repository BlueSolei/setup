#!/usr/bin/env bash
set -euo pipefail

install_and_start_ssh() {
  echo "Updating package lists..."
  sudo apt update

  echo "Installing OpenSSH server..."
  sudo apt install -y openssh-server

  echo "Enabling and starting SSH..."
  sudo systemctl enable --now ssh

  echo
  echo "SSH server status:"
  sudo systemctl --no-pager status ssh

  echo
  echo "Machine IP address(es):"
  hostname -I

  echo
  echo "From your machine, connect with either:"
  echo "  ssh $USER@$(hostname)"
  echo "  ssh $USER@<one-of-the-IPs-above>"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -h        Show this help and exit
  --sshd    Install and start the OpenSSH server
EOF
}

# Record the request in BOOTSTRAP_* variables. A new flag is a new variable here.
parse_args() {
  export BOOTSTRAP_HELP=0
  export BOOTSTRAP_SSHD=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h)
        BOOTSTRAP_HELP=1
        ;;
      --sshd)
        BOOTSTRAP_SSHD=1
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage >&2
        return 1
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  if [[ "$BOOTSTRAP_HELP" -eq 1 ]]; then
    usage
    return 0
  fi

  local ran_any=0

  if [[ "$BOOTSTRAP_SSHD" -eq 1 ]]; then
    install_and_start_ssh
    ran_any=1
  fi

  if [[ "$ran_any" -eq 0 ]]; then
    usage >&2
    return 1
  fi
}

main "$@"

