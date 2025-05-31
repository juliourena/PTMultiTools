#!/usr/bin/env bash
#
# set-dns.sh
#
#   Añade entradas DNS en /etc/hosts para una IP dada, y/o limpia entradas personalizadas.
#   Opciones:
#     -d      Modo Domain Controller (genera FQDN, dominio corto y host corto)
#     -c      Limpia las entradas personalizadas previas (todo después de '# Others')
#
# Uso:
#   sudo $0 [-d] [-c] <IP> <FQDN> [<alias1> <alias2> …]
#   sudo $0 -c    # Solo limpia entradas previas
#
# Ejemplos:
#   # Solo limpieza
#   sudo $0 -c
#
#   # modo DC, limpia antes de añadir
#   sudo $0 -c -d 10.129.104.26 DC.PUPPY.HTB
#
#   # modo manual, sin limpiar
#   sudo $0 10.129.104.26 DC.PUPPY.HTB PUPPY.HTB DC
#
# Autor: Plaintext (https://github.com/juliourena/PTMultiTools/bash/set-dns.sh)

set -euo pipefail

# Colores para la salida
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
NC='\e[0m'

# Banner inicial con autor y repositorio
echo -e "${YELLOW}***********************************************${NC}"
echo -e "${YELLOW}*  Script set-dns.sh by Plaintext             *${NC}"
echo -e "${YELLOW}*  https://github.com/juliourena/PTMultiTools *${NC}"
echo -e "${YELLOW}***********************************************${NC}"
echo ""

usage() {
  echo -e "${YELLOW}Uso:${NC} sudo $0 [-d] [-c] <IP> <FQDN> [<alias1> <alias2> …]"
  echo -e "  -d    Modo Domain Controller (añade FQDN, dominio corto y host corto)"
  echo -e "  -c    Limpia las entradas personalizadas previas (todo después de '# Others')"
  exit 1
}

# Comprobar ejecución como root
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}[-] Debes ejecutar este script como root (sudo).${NC}"
  exit 1
fi

# Flags por defecto
dc_mode=false
clean_mode=false

# Parsear opciones
while getopts ":dc" opt; do
  case "$opt" in
    d) dc_mode=true ;;
    c) clean_mode=true ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

# Si solo se pidió limpieza (-c) y no hay más argumentos, hacer solo eso y salir
if $clean_mode && [[ $# -eq 0 ]]; then
  echo -e "${YELLOW}[!] Limpiando entradas personalizadas (todo después de '# Others')...${NC}"
  cp /etc/hosts /etc/hosts.bak
  sed -i '/^# Others/,$d' /etc/hosts
  echo "# Others" >> /etc/hosts
  echo -e "${GREEN}[+] Limpieza completada. Backup en /etc/hosts.bak${NC}"
  exit 0
fi

# Validar argumentos para añadir entradas
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

# Realizar limpieza si se indicó junto con añadir
if $clean_mode; then
  echo -e "${YELLOW}[!] Limpiando entradas personalizadas (todo después de '# Others')...${NC}"
  cp /etc/hosts /etc/hosts.bak
  sed -i '/^# Others/,$d' /etc/hosts
  echo "# Others" >> /etc/hosts
  echo -e "${GREEN}[+] Limpieza completada. Backup en /etc/hosts.bak${NC}"
fi

#---------------------------------------------
# 1) Comprobar si ya existe una línea con esta IP
#---------------------------------------------
# Buscamos en /etc/hosts una línea que comience (opcionalmente con espacios) por la IP exacta seguida de un espacio o fin de línea:
existing_line=$(grep -E "^[[:space:]]*$IP([[:space:]]|$)" /etc/hosts || true)

if [[ -n "$existing_line" ]]; then
  # Si encontramos una línea, extraemos los hostnames actuales y los combinamos con los nuevos, evitando duplicados.
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

  echo -e "${GREEN}[+] IP encontrada en /etc/hosts. Se actualizó la línea existente con: ${new_entry}${NC}"
  echo -e "${GREEN}[+] Listo. (por Plaintext)${NC}"
  exit 0
fi

#---------------------------------------------
# 2) Si aquí, significa que la IP no existía: creamos la línea nueva
#---------------------------------------------
# Construir la línea a añadir
entry="$IP"
for name in "${hostnames[@]}"; do
  entry+=" $name"
done

# Insertar entrada justo debajo de marcador '# Others'
if grep -q '^# Others' /etc/hosts; then
  sed -i "/^# Others/a $entry" /etc/hosts
else
  echo "# Others" >> /etc/hosts
  echo "$entry" >> /etc/hosts
fi

echo -e "${GREEN}[+] Entrada aplicada:${NC} $entry"
echo -e "${GREEN}[+] Listo. (por Plaintext)${NC}"
