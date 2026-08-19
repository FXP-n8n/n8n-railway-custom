# n8n — official Docker image (npm install deprecated in n8n 3.0)
# Migration 2026-08-19: node:22-alpine + npm install -g n8n@latest  →  docker.io/n8nio/n8n
# NOTE: official image is Debian-based since ~1.100 (apk is gone; use apt-get).
# Version is pinned for controlled upgrades + real rollback path.
FROM docker.io/n8nio/n8n:2.35.3

# Extra OS deps (unchanged from previous image):
#   graphicsmagick — image node processing
#   tzdata         — timezone data
#   poppler-utils  — pdftoppm for QC drawing workflow
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends graphicsmagick tzdata poppler-utils && \
    rm -rf /var/lib/apt/lists/*

# n8n's image runs as user 'node' (uid 1000). Previous image ran as root and
# all volume files under /files are root-owned, so keep running as root.
USER root

# N8N_USER_FOLDER=/files is set in the Railway service env (state: /files/.n8n).
# DB + encryption key + webhook URL also come from service env — no build args.

EXPOSE 5678

# Railway sets $PORT at runtime; n8n reads N8N_PORT. Export at runtime, not build time.
CMD ["sh", "-c", "export N8N_PORT=$PORT && exec n8n start"]
