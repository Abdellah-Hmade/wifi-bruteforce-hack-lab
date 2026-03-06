# wifi-bruteforce-hack-lab

## Description

This project sets up a Docker-based lab environment for WiFi security testing and penetration testing. It uses the airgeddon tool along with simulated victim devices to create a controlled environment for learning and testing WiFi vulnerabilities.

## Features

- **Airgeddon Integration**: Runs the airgeddon WiFi auditing tool in a Docker container.
- **Simulated Victims**: Includes Docker containers simulating WPS-enabled access points and client devices.
- **Hardware Simulation**: Uses Linux kernel's `mac80211_hwsim` module to simulate multiple wireless interfaces.
- **Automated Setup**: Scripts to easily start and stop the lab environment.
- **Isolated Environment**: All components run in Docker containers for safety and isolation.

## Components

- `airgeddon-image/`: Docker setup for the airgeddon tool.
- `victim-lab/`: Simulated WPS victim access point.
- `victim-client/`: Simulated client device connecting to the victim.
- `from-scratch/`: Alternative Dockerfile for building from scratch.
- `create-hack-lab.sh`: Script to set up the lab.
- `shutdown-lab.sh`: Script to tear down the lab.

## Prerequisites

- Linux operating system (tested on Debian/Ubuntu)
- Docker and Docker Compose installed
- Root/sudo access
- Kernel module `mac80211_hwsim` available (usually included in Linux kernels)
- NetworkManager service
- `screen` utility for background processes

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd wifi-hack-image
   ```

2. Ensure Docker is running and you have sudo privileges.

3. (Optional) Build the Docker images if not using pre-built ones:
   ```bash
   cd victim-lab
   docker compose build
   ```

## Usage

1. **Start the Lab**:
   ```bash
   sudo ./create-hack-lab.sh
   ```
   This will:
   - Start NetworkManager
   - Load simulated wireless interfaces
   - Launch airgeddon in a screen session
   - Start the victim access point
   - Connect the victim client

2. **Access Airgeddon**:
   ```bash
   screen -r airgeddon
   ```

3. **Monitor Other Components**:
   ```bash
   screen -r wps_victim
   ```

## Shutdown

To cleanly shut down the lab:
```bash
sudo ./shutdown-lab.sh
```
This will kill all running processes, unload simulated interfaces, and stop NetworkManager.

## Configuration

- Modify `create-hack-lab.sh` for different numbers of simulated radios (default: 3).
- Edit `victim-lab/wps_lab.conf` and `victim-client/victim_phone.conf` for custom WPS configurations.
- Add dictionaries in `airgeddon-image/io/dictionaries/` for brute-force attacks.

## Options

`create-hack-lab.sh` supports:
- `--skip-deps`: Skip installing dependencies (screen)
- `-v, --verbose`: Enable verbose output
- `--config FILE`: Load custom configuration

`shutdown-lab.sh` supports:
- `-v, --verbose`: Enable verbose output

## Warnings

- **Educational Use Only**: This lab is for learning and testing in controlled environments. Do not use for unauthorized access.
- **Privileged Containers**: Containers run with `--privileged` and `network_mode: host` for hardware access.
- **System Impact**: Loading `mac80211_hwsim` may affect real wireless interfaces.
- **Legal Compliance**: Ensure compliance with local laws regarding wireless testing.

## Troubleshooting

- If `mac80211_hwsim` fails to load, check kernel modules: `modinfo mac80211_hwsim`
- Ensure no real wireless interfaces conflict with simulated ones.
- Run with verbose flags for detailed output.

## Contributing

Contributions welcome! Please test changes in the lab environment before submitting.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
