#!/bin/bash
set -e

# Check required env vars and set defaults
: "${PIHOLE_WEBPASSWORD:?Please set PIHOLE_WEBPASSWORD}"
: "${PIHOLE_PORT:=8089}"
: "${PIHOLE_TZ:=Africa/Johannesburg}"
: "${PIHOLE_DOMAIN_SUFFIX:=cagan.services}"
: "${PIHOLE_TARGET_IP:?Please set PIHOLE_TARGET_IP}"

echo "🛠️ Installing Pi-hole with these settings:"
echo " - WEBPASSWORD: ******"
echo " - PORT: $PIHOLE_PORT"
echo " - TIMEZONE: $PIHOLE_TZ"
echo " - DOMAIN SUFFIX: $PIHOLE_DOMAIN_SUFFIX"
echo " - TARGET IP: $PIHOLE_TARGET_IP"
echo

# Create working directory
WORKDIR="$HOME/pihole-deploy"
mkdir -p "$WORKDIR/etc-dnsmasq.d"
mkdir -p "$WORKDIR/etc-pihole"

# Write docker-compose.yml with env vars replaced
cat > "$WORKDIR/docker-compose.yml" <<EOF
version: "3.8"

services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    restart: unless-stopped
    hostname: pi
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "${PIHOLE_PORT}:80"
    environment:
      TZ: "${PIHOLE_TZ}"
      WEBPASSWORD: "${PIHOLE_WEBPASSWORD}"
    volumes:
      - ./etc-pihole:/etc/pihole
      - ./etc-dnsmasq.d:/etc/dnsmasq.d
    dns:
      - 127.0.0.1
    cap_add:
      - NET_ADMIN
EOF

# Write dnsmasq config for wildcard domain
cat > "$WORKDIR/etc-dnsmasq.d/99-custom.conf" <<EOF
address=/.${PIHOLE_DOMAIN_SUFFIX}/${PIHOLE_TARGET_IP}
EOF

echo "📁 Files created in $WORKDIR"

# Start Docker Compose
cd "$WORKDIR"
docker compose up -d

echo
echo "✅ Pi-hole deployed successfully!"
echo "Access the web UI at: http://$(hostname -I | awk '{print $1}'):${PIHOLE_PORT}/admin"
