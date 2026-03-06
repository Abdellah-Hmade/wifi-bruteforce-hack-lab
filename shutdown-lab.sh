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

# Kill xterm sessions
[[ $VERBOSE == true ]] && echo "Killing xterm lab windows"
pkill -f 'xterm -T airgeddon' 2>/dev/null || true
pkill -f 'xterm -T wps_victim' 2>/dev/null || true
pkill -f 'xterm -T victim_client' 2>/dev/null || true

# Stop and remove specific lab Docker containers
[[ $VERBOSE == true ]] && echo "Cleaning up Docker containers"
docker ps -a -q --filter "name=airgeddon" | xargs -r docker rm -f 2>/dev/null || true
docker ps -a -q --filter "name=wps_victim" | xargs -r docker rm -f 2>/dev/null || true

# Explicitly kill the wpa_supplicant and hostapd processes
[[ $VERBOSE == true ]] && echo "Cleaning up lingering networking processes"
pkill -f 'wpa_supplicant' 2>/dev/null || true
pkill -f 'hostapd' 2>/dev/null || true

# Unload module
[[ $VERBOSE == true ]] && echo "Unloading mac80211_hwsim module"
modprobe -r mac80211_hwsim 2>/dev/null || true

# Start NetworkManager
#[[ $VERBOSE == true ]] && echo "Starting NetworkManager"
#systemctl start NetworkManager 2>/dev/null || true

[[ $VERBOSE == true ]] && echo "Lab shutdown complete"