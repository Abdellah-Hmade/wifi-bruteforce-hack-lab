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
     DOCKER_PKG="docker.io"
elif command -v dnf &> /dev/null; then
     PKG_MANAGER="dnf"
     PKG_UPDATE="dnf check-update"
     PKG_INSTALL="dnf install -y"
     DOCKER_PKG="docker"
elif command -v pacman &> /dev/null; then
     PKG_MANAGER="pacman"
     PKG_UPDATE="pacman -Sy"
     PKG_INSTALL="pacman -S --noconfirm"
     DOCKER_PKG="docker"
else
     echo "Unsupported package manager"
     exit 1
fi

[[ $VERBOSE == true ]] && echo "Using package manager: $PKG_MANAGER"

# Function to check and install dependencies
check_and_install() {
    local cmd=$1
    local pkg=$2
    if ! command -v $cmd &> /dev/null; then
        [[ $VERBOSE == true ]] && echo "Installing $pkg"
        $PKG_UPDATE && $PKG_INSTALL $pkg
        if ! command -v $cmd &> /dev/null; then
            echo "Failed to install $pkg"
            exit 1
        fi
    else
        [[ $VERBOSE == true ]] && echo "$cmd is already installed"
    fi
}

# Check and install dependencies if not skipped
if [[ $SKIP_DEPS == false ]]; then
    check_and_install docker $DOCKER_PKG
    check_and_install xterm xterm
    check_and_install tmux tmux
    check_and_install wpa_supplicant wpasupplicant
fi

# Stop NetworkManager
#[[ $VERBOSE == true ]] && echo "Stopping NetworkManager"
#systemctl stop NetworkManager 2>/dev/null || true

# Unload module
[[ $VERBOSE == true ]] && echo "loading mac80211_hwsim module"
modprobe mac80211_hwsim radios=3

# Spawn new terminal windows for each process
# Airgeddon gets wrapped in a tmux session inside xterm so its multi-window attacks work
# Pass the AIRGEDDON_WINDOWS_HANDLING variable to force Airgeddon to use tmux internally
xterm -T "airgeddon" -e bash -c "cd ./airgeddon-image && docker compose run -it -e AIRGEDDON_WINDOWS_HANDLING=tmux --rm airgeddon; exec bash" &
xterm -T "wps_victim" -e bash -c "cd ./victim-lab && docker compose run --rm wps_victim; exec bash" &
xterm -T "victim_client" -e bash -c "cd ./victim-client && wpa_supplicant -i wlan2 -c victim_phone.conf; exec bash" &

[[ $VERBOSE == true ]] && echo "Lab setup complete"