# PTMultiTools

PTMultiTools es una colección de scripts públicos diseñados tanto para desafíos CTF como para usos en el mundo real. Estas utilidades están organizadas en directorios y buscan agilizar tareas comunes de redes y pentesting.

**Autor:** Plaintext  
**Repositorio:** [github.com/juliourena/PTMultiTools](https://github.com/juliourena/PTMultiTools)

---

## Herramientas

- **`bash/ES/set-dns.sh`**  
  Un script para gestionar entradas DNS personalizadas en `/etc/hosts`. Puede limpiar entradas previas o insertar nuevas (combinándolas con líneas existentes si es necesario), con un modo opcional de “Controlador de Dominio” que añade campos de FQDN, dominio corto y nombre de host corto.

- **`bash/ES/escanear.sh`**  
  Un script de escaneo de puertos en varias fases que ejecuta un escaneo TCP completo en todos los puertos, continúa con un chequeo de servicios/versiones (`-sC -sV`) en los puertos TCP abiertos detectados, y luego repite verificaciones similares en los puertos UDP por defecto. Las salidas se almacenan en archivos separados para cada fase.

---

## Esquema de Uso

- Clona el repositorio y navega hasta la carpeta `bash/ES/`.
- Cada script requiere ejecución con privilegios de root (por ejemplo, `sudo`), ya que modifican archivos del sistema y ejecutan escaneos con nmap.

Los ejemplos detallados de uso y las opciones se documentan dentro de cada script individual.

---

## Licencia

Este proyecto se distribuye bajo la Licencia Apache 2.0. Consulta el archivo [LICENSE](LICENSE) para ver los términos completos.

---

Para cualquier pregunta o contribución, siéntete libre de abrir un issue o enviar un pull request.```
