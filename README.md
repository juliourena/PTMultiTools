# PTMultiTools

PTMultiTools is a collection of public scripts designed for both CTF challenges and real-world engagements. These utilities are organized under directories and aim to streamline common networking and pentesting tasks.

**Author:** Plaintext  
**Repository:** [github.com/juliourena/PTMultiTools](https://github.com/juliourena/PTMultiTools)

---

## Tools

- **`bash/set-dns.sh`**  
  A script to manage custom DNS entries in `/etc/hosts`. It can clean previous entries or insert new ones (merging with existing lines if necessary), with an optional “Domain Controller mode” that adds fully qualified, short-domain, and hostname fields.

- **`bash/escanear.sh`**  
  A multi-phase port scanning script that runs a full TCP scan against all ports, follows up with a `-sC -sV` service/version check on any discovered TCP ports, and then repeats similar checks for default UDP ports. Outputs are stored in separate files for each phase.

---

## Usage Outline

- Clone the repo and navigate to the `bash/` folder.
- Each script requires execution with root privileges (e.g., `sudo`) because they modify system files and run nmap scans.

Detailed usage examples and options are documented within each individual script.

---

## License

This project is distributed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for full terms.

---

For any questions or contributions, feel free to open an issue or submit a pull request.
