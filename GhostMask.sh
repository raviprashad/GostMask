#!/bin/bash

# Check for root
if [[ $EUID -ne 0 ]]; then
  echo "[!] Please run as root"
  exit 1
fi

# Detect active network interface
IFACE=$(ip route | awk '/default/ {print $5}')

if [[ -z "$IFACE" ]]; then
  echo "[!] Network interface not found"
  exit 1
fi

# Get original MAC address
ORIGINAL_MAC=$(cat /sys/class/net/$IFACE/address)

# Function to generate random valid MAC
generate_random_mac() {
  printf '02:%02x:%02x:%02x:%02x:%02x\n' \
    $((RANDOM%256)) $((RANDOM%256)) \
    $((RANDOM%256)) $((RANDOM%256)) \
    $((RANDOM%256))
}

# Function to validate MAC address
validate_mac() {
  [[ $1 =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]
}

# Function to change MAC
change_mac() {
  ip link set $IFACE down
  ip link set $IFACE address "$1"
  ip link set $IFACE up
}

# ---------------- MENU ----------------

clear
echo "===================================="
echo "        MAC SPOOFING TOOL            "
echo "===================================="
echo "[*] Interface     : $IFACE"
echo "[*] Original MAC  : $ORIGINAL_MAC"
echo "------------------------------------"
echo "1) Assign Random MAC Address"
echo "2) Assign Custom MAC Address"
echo "------------------------------------"
read -p "Enter your choice: " choice

case $choice in
  1)
    NEW_MAC=$(generate_random_mac)
    echo "[*] Random MAC Generated: $NEW_MAC"
    change_mac "$NEW_MAC"
    echo "[+] MAC address changed successfully"
    ;;
  2)
    read -p "Enter new MAC address (XX:XX:XX:XX:XX:XX): " CUSTOM_MAC
    if validate_mac "$CUSTOM_MAC"; then
      change_mac "$CUSTOM_MAC"
      echo "[+] MAC address changed successfully"
    else
      echo "[!] Invalid MAC address format"
    fi
    ;;
  *)
    echo "[!] Invalid option"
    ;;
esac
