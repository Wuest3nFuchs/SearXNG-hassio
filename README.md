# SearxNG — Home Assistant Supervisor Add-on

Dieses Repository enthält ein production‑taugliches Home Assistant Supervisor Add‑on, das SearxNG als interne Such‑Engine bereitstellt. Das Add‑on unterstützt Ingress, persistente Speicherung von Konfiguration/DB, konfigurierbare Ports und Versionierung des SearxNG-Pakets.

## Inhalt
- config.json — Add‑on Metadaten und Optionen
- Dockerfile — Produktionsimage mit runtime-installation von SearxNG
- entrypoint.sh, run.sh — Startup/Entrypoint-Skripte
- default_searxng_settings.yml — empfohlene Produktionskonfiguration
- logo.png — optionales Icon

## Voraussetzungen
- Home Assistant OS mit Supervisor (lokal)
- Schreibzugriff auf /share (Supervisor Share) für Persistenz
- Grundkenntnisse: Add‑on Installation, Editieren von YAML

## Installation
1. Repository in ein Git-Repo packen oder als lokales Verzeichnis bereitstellen.
2. Home Assistant → Supervisor → Add‑on‑Store → Drei‑Punkte → "Repositories" → "Repository hinzufügen" → URL oder Pfad deines Repos.
3. In Add‑on‑Store "SearxNG" auswählen, installieren.
4. Unter "Configuration" die Optionen setzen (siehe unten).
5. Installieren und starten. Bei aktivierter Ingress über Supervisor → SearxNG → "Open Web UI" öffnen.

## Optionen (config.json)
- listen_port (int, default 8080) — interner HTTP-Port.
- base_url (string|null) — Basispfad, wenn hinter Reverse‑Proxy oder Ingress.
- bind_address (string, default "0.0.0.0") — Interface.
- searxng_version (string, default "latest") — pip-Version von SearxNG.
- persistence_enable (bool, default true) — Persistente Speicherung aktivieren.
- persistence_path (string, default "/share/searxng") — Pfad auf Host für persistente Daten.
- secret_key (string, optional) — optionaler Security Secret Key; wird generiert, falls leer.

## Persistenz
- Standardpfad: /share/searxng (muss in config.json als map vorhanden sein).
- Struktur (bei aktivierter Persistenz):
  - settings/settings.yml
  - var/ (DB, cache)

## Sicherheitsempfehlungen
- Verwende Ingress (empfohlen) oder setze HTTPS + Auth im Reverse Proxy.
- Setze ein starkes secret_key, falls die Instanz extern erreichbar ist.
- Aktiviere rate limiting und sichere API‑Keys.

## Updates & Backup
- Update via Änderung der Option `searxng_version` und Neustart.
- Backup: /share/searxng/settings.yml und /share/searxng/var/searxng.db sichern.

## Troubleshooting
- Logs: Supervisor → Add‑on → Log.
- Häufige Fehler:
  - Fehlende Schreibrechte auf /share: prüfen.
  - Pip-Install schlägt fehl: Netzwerk/Zugang prüfen.
  - Port-Konflikte: Host-Port prüfen, bei Ingress kein externer Port nötig.

## Entwicklung & Debug
- Lokal bauen:
  docker build -t searxng-addon .
  docker run -it --rm -p 8080:8080 -v /path/to/share/searxng:/share/searxng searxng-addon

## Lizenz & Quellen
- Add‑on: Passe Lizenz/Author nach Bedarf an.
- SearxNG upstream: https://github.com/searxng/searxng
- Docker image reference: https://hub.docker.com/r/searxng/searxng
