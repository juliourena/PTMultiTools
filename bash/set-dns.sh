#!/usr/bin/env bash
#
# set-dns.sh
#
#   Adds DNS entries to /etc/hosts for a given IP, and/or clears previous custom entries.
#   Options:
#     -d      Domain Controller mode (generates FQDN, short domain, and short host)
#     -c      Clears previous custom entries (everything after '# Others')
#
# Usage:
#   sudo $0 [-d] [-c] <IP> <FQDN> [<alias1> <alias2> …]
#   sudo $0 -c    # Only clear previous entries
#
# Examples:
#   # Only clear
#   sudo $0 -c
#
#   # DC mode, clear then add
#   sudo $0 -c -d 10.129.104.26 DC.PUPPY.HTB
#
#   # Manual mode, without clearing
#   sudo $0 10.129.104.26 DC.PUPPY.HTB PUPPY.HTB DC
#
# Author: Plaintext (https://github.com/juliourena/PTMultiTools/bash/set-dns.sh)

set -euo pipefail

# Colors for output
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
NC='\e[0m'

# Initial banner with author and repository
echo -e "${YELLOW}***********************************************${NC}"
echo -e "${YELLOW}*  Script set-dns.sh by Plaintext             *${NC}"
echo -e "${YELLOW}*  https://github.com/juliourena/PTMultiTools *${NC}"
echo -e "${YELLOW}***********************************************${NC}"
echo ""

usage() {
  echo -e "${YELLOW}Usage:${NC} sudo $0 [-d] [-c] <IP> <FQDN> [<alias1> <alias2> …]"
  echo -e "  -d    Domain Controller mode (adds FQDN, short domain, and short host)"
  echo -e "  -c    Clears previous custom entries (everything after '# Others')"
  exit 1
}

# Check for root execution
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}[-] You must run this script as root (sudo).${NC}"
  exit 1
fi

# Default flags
dc_mode=false
clean_mode=false

# Parse options
while getopts ":dc" opt; do
  case "$opt" in
    d) dc_mode=true ;;
    c) clean_mode=true ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

# If only clearing (-c) and no other arguments, perform clear and exit
if $clean_mode && [[ $# -eq 0 ]]; then
  echo -e "${YELLOW}[!] Clearing custom entries (everything after '# Others')...${NC}"
  cp /etc/hosts /etc/hosts.bak
  sed -i '/^# Others/,$d' /etc/hosts
  echo "# Others" >> /etc/hosts
  echo -e "${GREEN}[+] Clear completed. Backup saved to /etc/hosts.bak${NC}"
  exit 0
fi

# Validate arguments for adding entries
if $dc_mode; then
  [[ $# -eq 2 ]] || usage
  IP="$1"
  FQDN="$2"
  host_short="${FQDN%%.*}"
  domain_short="${FQDN#*.}"
  hostnames=("$FQDN" "$domain_short" "$host_short")
else
  [[ $# -ge 2 ]] || usage
  IP="$1"; shift
  hostnames=("$@")
fi

# Perform clear if specified alongside add
if $clean_mode; then
  echo -e "${YELLOW}[!] Clearing custom entries (everything after '# Others')...${NC}"
  cp /etc/hosts /etc/hosts.bak
  sed -i '/^# Others/,$d' /etc/hosts
  echo "# Others" >> /etc/hosts
  echo -e "${GREEN}[+] Clear completed. Backup saved to /etc/hosts.bak${NC}"
fi

#---------------------------------------------
# 1) Check if a line with this IP already exists
#---------------------------------------------
# Search /etc/hosts for a line that begins (optionally with spaces) with the exact IP followed by space or end of line:
existing_line=$(grep -E "^[[:space:]]*$IP([[:space:]]|$)" /etc/hosts || true)

if [[ -n "$existing_line" ]]; then
  # If found, extract existing hostnames and merge with new ones, avoiding duplicates.
  existing_names_str=$(echo "$existing_line" | awk '{$1=""; sub(/^ /, ""); print}')
  read -r -a existing_names_array <<< "$existing_names_str"

  combined_names=()
  for name in "${existing_names_array[@]}"; do
    if [[ ! " ${combined_names[*]} " =~ " $name " ]]; then
      combined_names+=("$name")
    fi
  done
  for name in "${hostnames[@]}"; do
    if [[ ! " ${combined_names[*]} " =~ " $name " ]]; then
      combined_names+=("$name")
    fi
  done

  new_entry="$IP ${combined_names[*]}"

  sed -i -E "0,/^[[:space:]]*$IP([[:space:]]|$)/s|^[[:space:]]*$IP([[:space:]].*)?$|$new_entry|" /etc/hosts

  echo -e "${GREEN}[+] IP found in /etc/hosts. Updated existing line to: ${new_entry}${NC}"
  echo -e "${GREEN}[+] Done. (by Plaintext)${NC}"
  exit 0
fi

#---------------------------------------------
# 2) If we reach here, the IP did not exist: create a new line
#---------------------------------------------
# Construct the line to add
entry="$IP"
for name in "${hostnames[@]}"; do
  entry+=" $name"
done

# Insert the entry just below the '# Others' marker
if grep -q '^# Others' /etc/hosts; then
  sed -i "/^# Others/a $entry" /etc/hosts
else
  echo "# Others" >> /etc/hosts
  echo "$entry" >> /etc/hosts
fi

echo -e "${GREEN}[+] Entry applied:${NC} $entry"
echo -e "${GREEN}[+] Done. (by Plaintext)${NC}"
