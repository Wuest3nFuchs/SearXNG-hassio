SearxNG Home Assistant Add-on
=============================

Dieses Add-on verwendet das offizielle Docker-Image searxng/searxng und stellt eine lokale Instanz von SearxNG bereit.

Installation
1. Lege den Ordner /addons/local/searxng an (Samba oder SSH).
2. Kopiere die Dateien config.json, options.json und optional run.sh und icon.png in den Ordner.
3. Falls run.sh verwendet wird: chmod +x run.sh
4. Supervisor neu starten, falls das Add-on nicht automatisch erscheint:
   - Home Assistant → Einstellungen → System → Host → Neustart
   - oder per SSH: ha supervisor restart
5. Home Assistant → Supervisor → Add-on-Store → Lokale Add-ons → SearxNG → Install.

Konfiguration
- Persistente Konfiguration liegt unter /addons/local/searxng/config (enthält settings.yml).
- Standard-Host-Port: 8080 (anpassbar in config.json / options.json).

Starten und Logs
- Add-on starten in Supervisor UI.
- Logs: Supervisor → Add-on → Logs.

Hinweise
- Wenn Port 8080 belegt ist, ändere das Mapping in config.json (z. B. "8080/tcp": 9000).
- Änderungen an /config erfordern meist einen Neustart des Add-ons.
