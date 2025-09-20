## README — SearxNG Home Assistant Add-on

Kurzanleitung zum lokalen Add‑on „SearxNG“ für Home Assistant Supervisor.

### Was ist das?
Dieses Add‑on nutzt das offizielle Docker‑Image searxng/searxng und stellt eine selbst gehostete Suchmaschine bereit.

### Installation
1. Lege den Ordner /addons/local/searxng auf deinem Home Assistant Host an (Samba oder SSH).
2. Kopiere diese Dateien in den Ordner:
   - config.json
   - options.json
   - optional: run.sh (ausführbar, chmod +x)
   - optional: icon.png
   - optional: README.md (diese Datei)

3. Supervisor neu laden (falls Add‑on nicht automatisch erscheint):
   - Home Assistant → Einstellungen → System → Host → Neustart
   - Oder per SSH: ha supervisor restart

4. Öffne Home Assistant → Supervisor → Add‑on‑Store → Lokale Add‑ons → SearxNG → Install.

### Konfiguration
- Standard‑Optionen (options.json):
  - port: Host‑Port, standard 8080
  - searx_profile_path: Pfad innerhalb des Add‑on‑Mounts für SearxNG Konfiguration (/config/searxng)
  - extra_env: zusätzliche Umgebungsvariablen (leer)

- Mappings/Pfade:
  - /addons/local/searxng/config auf Container /config (persistent)
  - /addons/local/searxng/ssl auf Container /ssl (optional)

Wenn du den Host‑Port ändern willst, passe die Ports‑Zuordnung in config.json an (z. B. "8080/tcp": 9000 für Host‑Port 9000).

### Optional: Eigene SearxNG Einstellungen
Lege Konfigurationsdateien unter /addons/local/searxng/config ab. Beispiel minimal settings.yml:

http server:
  bind_address: 0.0.0.0
  port: 8080

Nach Änderungen Add‑on stoppen und neu starten.

### Startscript (optional)
Wenn du run.sh verwendest, mache es ausführbar:
chmod +x /addons/local/searxng/run.sh

Einfaches run.sh erzeugt bei Bedarf das Config‑Verzeichnis und startet das Image.

### Logs & Troubleshooting
- Logs: Home Assistant → Supervisor → Add‑on → Logs
- Häufige Probleme:
  - Port belegt → anderen Host‑Port in config.json wählen.
  - Config nicht übernommen → prüfe, ob Dateien unter /addons/local/searxng/config liegen.
  - Image zieht nicht → Internetverbindung prüfen.

### Sicherheit & Zugriff
SearxNG läuft lokal auf dem Host. Wenn du Zugriff von außen erlauben willst, richte Port‑Weiterleitung/Firewall entsprechend ein (auf eigenes Risiko).

### Hinweise
- Dieses Add‑on nutzt das offizielle Docker‑Image; keine Anpassung des Images nötig.
- Bei größeren Anpassungen kannst du ein eigenes Dockerfile verwenden, dann muss config.json angepasst werden.

Wenn du möchtest, erstelle ich dir jetzt die exakten Datei‑Inhalte (config.json, options.json, run.sh und settings.yml) als Textblöcke zum Kopieren.