#!/usr/bin/env bash
#
# escanear.sh
#
#   Escanea puertos TCP y UDP de una IP, extrae puertos abiertos y lanza detección de servicios/versiones.
#   Realiza en total 4 escaneos:
#     1) TCP full (puertos 1–65535, valores por defecto de nmap)
#     2) TCP con -sC -sV en los puertos abiertos detectados
#     3) UDP normal (puertos por defecto de nmap para UDP)
#     4) UDP con -sC -sV en los puertos UDP abiertos detectados
#
# Uso:
#   sudo ./escanear.sh <IP>
#
# Ejemplo:
#   sudo ./escanear.sh 10.129.104.26
#
# Autor: Plaintext
# Repo:   https://github.com/juliourena/PTMultiTools/bash/escanear.sh

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "[-] Uso: $0 <IP>"
  exit 1
fi

IP="$1"

# Archivos de salida para cada escaneo
TCP_FULL_GREPPABLE="${IP}-tcp-full.nmap"
TCP_SCV_OUT="${IP}-tcp-sCV.nmap"
UDP_GREPPABLE="${IP}-udp-default.nmap"
UDP_SCV_OUT="${IP}-udp-sCV.nmap"

echo "=============================================="
echo "[+] Script de escaneo por Plaintext"
echo "[+] Repositorio: https://github.com/juliourena/PTMultiTools/bash/escanear.sh"
echo "=============================================="
echo ""

# 1) Escaneo TCP full (todos los puertos), con valores por defecto de nmap
echo "[+] 1) Iniciando escaneo TCP full (puertos 1-65535) en $IP..."
nmap -p- "$IP" -oG "$TCP_FULL_GREPPABLE" -vv
echo "[+] Escaneo TCP full finalizado. Salida greppable: $TCP_FULL_GREPPABLE"
echo ""

# 2) Extracción de puertos TCP abiertos del escaneo full
echo "[+] 2) Extrayendo puertos TCP abiertos de $TCP_FULL_GREPPABLE..."
tcp_ports=$(grep -oE '[0-9]+/open' "$TCP_FULL_GREPPABLE" \
            | cut -d/ -f1 \
            | paste -sd, -)
if [ -z "$tcp_ports" ]; then
  echo "[-] No se encontraron puertos TCP abiertos en $IP."
else
  echo "[+] Puertos TCP abiertos detectados: $tcp_ports"
  echo "[+] Iniciando escaneo TCP -sC -sV en los puertos abiertos..."
  sudo nmap -sC -sV -p"$tcp_ports" "$IP" -oN "$TCP_SCV_OUT"
  echo "[+] Escaneo TCP -sC -sV finalizado. Resultados: $TCP_SCV_OUT"
fi
echo ""

# 3) Escaneo UDP normal (puertos por defecto)
echo "[+] 3) Iniciando escaneo UDP normal (puertos por defecto) en $IP..."
sudo nmap -sU "$IP" -oG "$UDP_GREPPABLE" -vv
echo "[+] Escaneo UDP normal finalizado. Salida greppable: $UDP_GREPPABLE"
echo ""

# 4) Extracción de puertos UDP abiertos del escaneo normal
echo "[+] 4) Extrayendo puertos UDP abiertos de $UDP_GREPPABLE..."
udp_ports=$(grep -oE '[0-9]+/open' "$UDP_GREPPABLE" \
            | cut -d/ -f1 \
            | paste -sd, -)
if [ -z "$udp_ports" ]; then
  echo "[-] No se encontraron puertos UDP abiertos en $IP."
else
  echo "[+] Puertos UDP abiertos detectados: $udp_ports"
  echo "[+] Iniciando escaneo UDP -sC -sV en los puertos abiertos..."
  sudo nmap -sU -sC -sV -p"$udp_ports" "$IP" -oN "$UDP_SCV_OUT"
  echo "[+] Escaneo UDP -sC -sV finalizado. Resultados: $UDP_SCV_OUT"
fi
echo ""

echo "[+] Todos los escaneos han concluido."
echo "[+] Archivos generados:"
echo "    • TCP full greppable : $TCP_FULL_GREPPABLE"
echo "    • TCP -sC -sV       : $TCP_SCV_OUT"
echo "    • UDP normal greppable: $UDP_GREPPABLE"
echo "    • UDP -sC -sV       : $UDP_SCV_OUT"
echo "=============================================="
