# Use Debian's lightweight "slim" image
FROM debian:bookworm-slim

# Install hostapd and networking tools (Debian's hostapd includes WPS)
RUN apt-get update && \
    apt-get install -y --no-install-recommends hostapd iw iproute2 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the configuration file
COPY wps_lab.conf /app/wps_lab.conf

# Run hostapd in debug mode
CMD ["hostapd", "-d", "/app/wps_lab.conf"]
