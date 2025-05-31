#!/usr/bin/env bash
#
# scan.sh
#
#   Scans TCP and UDP ports on an IP, extracts open ports, and runs service/version detection.
#   Performs a total of 4 scans:
#     1) Full TCP scan (ports 1–65535, nmap defaults)
#     2) TCP scan with -sC -sV on detected open ports
#     3) Normal UDP scan (nmap’s default UDP port list)
#     4) UDP scan with -sC -sV on detected open UDP ports
#
# Usage:
#   sudo ./scan.sh <IP>
#
# Example:
#   sudo ./scan.sh 10.129.104.26
#
# Author: Plaintext
# Repo:   https://github.com/juliourena/PTMultiTools/bash/escanear.sh

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "[-] Usage: $0 <IP>"
  exit 1
fi

IP="$1"

# Output files for each scan
TCP_FULL_GREPPABLE="${IP}-tcp-full.nmap"
TCP_SCV_OUT="${IP}-tcp-sCV.nmap"
UDP_GREPPABLE="${IP}-udp-default.nmap"
UDP_SCV_OUT="${IP}-udp-sCV.nmap"

echo "=============================================="
echo "[+] Scan script by Plaintext"
echo "[+] Repository: https://github.com/juliourena/PTMultiTools/bash/escanear.sh"
echo "=============================================="
echo ""

# 1) Full TCP scan (all ports), using nmap defaults
echo "[+] 1) Starting full TCP scan (ports 1-65535) on $IP..."
nmap -p- "$IP" -oG "$TCP_FULL_GREPPABLE" -vv
echo "[+] Full TCP scan completed. Greppable output: $TCP_FULL_GREPPABLE"
echo ""

# 2) Extract open TCP ports from the full scan
echo "[+] 2) Extracting open TCP ports from $TCP_FULL_GREPPABLE..."
tcp_ports=$(grep -oE '[0-9]+/open' "$TCP_FULL_GREPPABLE" \
            | cut -d/ -f1 \
            | paste -sd, -)
if [ -z "$tcp_ports" ]; then
  echo "[-] No open TCP ports found on $IP."
else
  echo "[+] Detected open TCP ports: $tcp_ports"
  echo "[+] Starting TCP -sC -sV scan on those ports..."
  sudo nmap -sC -sV -p"$tcp_ports" "$IP" -oN "$TCP_SCV_OUT"
  echo "[+] TCP -sC -sV scan completed. Results: $TCP_SCV_OUT"
fi
echo ""

# 3) Normal UDP scan (default UDP ports)
echo "[+] 3) Starting normal UDP scan (default ports) on $IP..."
sudo nmap -sU "$IP" -oG "$UDP_GREPPABLE" -vv
echo "[+] Normal UDP scan completed. Greppable output: $UDP_GREPPABLE"
echo ""

# 4) Extract open UDP ports from the normal scan
echo "[+] 4) Extracting open UDP ports from $UDP_GREPPABLE..."
udp_ports=$(grep -oE '[0-9]+/open' "$UDP_GREPPABLE" \
            | cut -d/ -f1 \
            | paste -sd, -)
if [ -z "$udp_ports" ]; then
  echo "[-] No open UDP ports found on $IP."
else
  echo "[+] Detected open UDP ports: $udp_ports"
  echo "[+] Starting UDP -sC -sV scan on those ports..."
  sudo nmap -sU -sC -sV -p"$udp_ports" "$IP" -oN "$UDP_SCV_OUT"
  echo "[+] UDP -sC -sV scan completed. Results: $UDP_SCV_OUT"
fi
echo ""

echo "[+] All scans have finished."
echo "[+] Files generated:"
echo "    • TCP full greppable  : $TCP_FULL_GREPPABLE"
echo "    • TCP -sC -sV         : $TCP_SCV_OUT"
echo "    • UDP normal greppable: $UDP_GREPPABLE"
echo "    • UDP -sC -sV         : $UDP_SCV_OUT"
echo "=============================================="
