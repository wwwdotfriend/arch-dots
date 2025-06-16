#!/usr/bin/env bash

# This script gathers detailed Ethernet connection information.
# It collects the following fields:
#
# - Connection Name: The name of the active ethernet connection profile
#   in NetworkManager. Example: "Wired connection 1"
#
# - IP Address: The IP address assigned to the device by the router/DHCP.
#   This is typically a private IP within the local network. Example:
#   "192.168.1.100/24" (with subnet mask)
#
# - Gateway: The IP address of the router (default gateway) that your
#   device uses to communicate outside the local network.
#   Example: "192.168.1.1"
#
# - MAC Address: The unique Media Access Control address of the ethernet
#   adapter. Example: "AA:BB:CC:DD:EE:FF"
#
# - Link Speed: The negotiated connection speed between your network card
#   and the switch/router. Common speeds include 10 Mbps, 100 Mbps,
#   1000 Mbps (1 Gbps), etc. Example: "1000 Mb/s"
#
# - Duplex Mode: Whether the connection can send and receive data
#   simultaneously (full) or only one direction at a time (half).
#   Example: "full" (almost always full-duplex on modern networks)
#
# - DNS Servers: The DNS servers being used for domain name resolution.
#   Example: "8.8.8.8, 1.1.1.1"
#
# - Device State: The current state of the ethernet interface.
#   Example: "connected", "disconnected", "unavailable"

if ! command -v nmcli &>/dev/null; then
  echo "{\"text\": \"󰌗\", \"tooltip\": \"nmcli utility is missing\"}"
  exit 1
fi

# Get active ethernet device
active_device=$(nmcli -t -f DEVICE,TYPE,STATE device status | 
  grep "ethernet:connected" | 
  head -n1 | 
  awk -F: '{print $1}')

if [ -z "$active_device" ]; then
  # Check if there are any ethernet devices at all
  ethernet_devices=$(nmcli -t -f DEVICE,TYPE device status | grep "ethernet" | wc -l)
  
  if [ "$ethernet_devices" -eq 0 ]; then
    echo "{\"text\": \"󰌗\", \"tooltip\": \"No ethernet devices found\"}"
  else
    # There are ethernet devices but none connected
    echo "{\"text\": \"󰌙\", \"tooltip\": \"Ethernet disconnected\"}"
  fi
  exit 0
fi

# Get connection name separately
connection_name=$(nmcli -t -f GENERAL.CONNECTION device show "$active_device" | cut -d: -f2)

# Get connection details using correct field names
connection_info=$(nmcli -e no -g IP4.ADDRESS,IP4.GATEWAY,GENERAL.HWADDR,IP4.DNS device show "$active_device")

ip_address=$(echo "$connection_info" | sed -n '1p')
gateway=$(echo "$connection_info" | sed -n '2p')
mac_address=$(echo "$connection_info" | sed -n '3p')
dns_servers=$(echo "$connection_info" | sed -n '4p')

# Get link speed and duplex if ethtool is available
link_speed="N/A"
duplex="N/A"

if command -v ethtool &>/dev/null; then
  ethtool_output=$(ethtool "$active_device" 2>/dev/null)
  if [ $? -eq 0 ]; then
    link_speed=$(echo "$ethtool_output" | grep "Speed:" | awk '{print $2}')
    duplex=$(echo "$ethtool_output" | grep "Duplex:" | awk '{print $2}')
  fi
fi

# Clean up DNS servers display (remove extra spaces, limit to first 2)
if [ -n "$dns_servers" ] && [ "$dns_servers" != "--" ]; then
  dns_display=$(echo "$dns_servers" | tr '|' ',' | sed 's/,/, /g' | cut -d',' -f1,2)
else
  dns_display="N/A"
fi

# Build tooltip
tooltip=":: ${connection_name}"
tooltip+="\nDevice:     ${active_device}"
tooltip+="\nIP Address: ${ip_address:-N/A}"
tooltip+="\nGateway:    ${gateway:-N/A}"
tooltip+="\nMAC:        ${mac_address:-N/A}"
tooltip+="\nSpeed:      ${link_speed}"
tooltip+="\nDuplex:     ${duplex}"
tooltip+="\nDNS:        ${dns_display}"

# Determine icon based on connection status and speed
icon="󰈀" # Default connected ethernet icon

# If we have speed info, we could vary the icon
if [ "$link_speed" != "N/A" ]; then
  case "$link_speed" in
    *"10000"*|*"10Gb"*)
      icon="󰈁" # High-speed ethernet
      ;;
    *"1000"*|*"1Gb"*)
      icon="󰈀" # Gigabit ethernet  
      ;;
    *"100"*|*"10"*)
      icon="󰈀" # Standard ethernet
      ;;
  esac
fi

# Output for waybar
echo "{\"text\": \"${icon}\", \"tooltip\": \"${tooltip}\"}"3