#!/bin/bash

# Default configuration
RADIOS=3
SKIP_DEPS=false
VERBOSE=false

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help              Show this help message
  --skip-deps             Skip dependency installation
  -v, --verbose           Enable verbose output
  --config FILE           Load configuration from file

Examples:
  $(basename "$0") --skip-deps --verbose

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --config)
            source "$2"
            shift 2
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

# Detect package manager
if command -v apt &> /dev/null; then
     PKG_MANAGER="apt"
     PKG_UPDATE="apt update"
     PKG_INSTALL="apt install -y"
elif command -v dnf &> /dev/null; then
     PKG_MANAGER="dnf"
     PKG_UPDATE="dnf check-update"
     PKG_INSTALL="dnf install -y"
elif command -v pacman &> /dev/null; then
     PKG_MANAGER="pacman"
     PKG_UPDATE="pacman -Sy"
     PKG_INSTALL="pacman -S --noconfirm"
else
     echo "Unsupported package manager"
     exit 1
fi

[[ $VERBOSE == true ]] && echo "Using package manager: $PKG_MANAGER"

# Check if mac80211_hwsim module exists
if ! modinfo mac80211_hwsim &> /dev/null; then
     echo "mac80211_hwsim module not found"
     exit 1
fi

# Execute commands
systemctl start NetworkManager
[[ $VERBOSE == true ]] && echo "Loading mac80211_hwsim with $RADIOS radios"
modprobe mac80211_hwsim radios=$RADIOS

if [[ $SKIP_DEPS == false ]]; then
    $PKG_UPDATE && $PKG_INSTALL screen
fi

screen -d -m -S airgeddon bash -c "cd ./airgeddon-image && docker compose run --rm airgeddon"
screen -d -m -S wps_victim bash -c "cd ./victim-lab && docker compose run --rm wps_victim"
screen -d -m -S wps_victim bash -c "cd ./victim-client && wpa_supplicant -i wlan2 -c victim_phone.conf"

[[ $VERBOSE == true ]] && echo "Lab setup complete"