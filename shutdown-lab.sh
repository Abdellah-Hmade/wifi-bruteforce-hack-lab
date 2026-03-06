#!/bin/bash

# Default configuration
VERBOSE=false

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help              Show this help message
  -v, --verbose           Enable verbose output

Examples:
  $(basename "$0") --verbose

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Check if running with sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Kill screen sessions
[[ $VERBOSE == true ]] && echo "Killing screen sessions"
screen -S airgeddon -X quit 2>/dev/null || true
screen -S wps_victim -X quit 2>/dev/null || true

# Unload module
[[ $VERBOSE == true ]] && echo "Unloading mac80211_hwsim module"
modprobe -r mac80211_hwsim 2>/dev/null || true

# Stop NetworkManager
[[ $VERBOSE == true ]] && echo "Stopping NetworkManager"
systemctl stop NetworkManager 2>/dev/null || true

[[ $VERBOSE == true ]] && echo "Lab shutdown complete"