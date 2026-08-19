# n8n — official Docker image (npm install deprecated in n8n 3.0)
# Migration 2026-08-19: node:22-alpine + npm install -g n8n@latest  →  docker.io/n8nio/n8n
# Version is pinned for controlled upgrades + real rollback path.
FROM docker.io/n8nio/n8n:2.35.3

# Extra OS deps (unchanged from previous image):
#   graphicsmagick — image node processing
#   tzdata         — timezone data
#   poppler-utils  — pdftoppm for QC drawing workflow
USER root
RUN apk add --no-cache graphicsmagick tzdata poppler-utils

# n8n's image runs as user 'node' (uid 1000). Previous image ran as root and
# all volume files under /files are root-owned, so keep running as root.
USER root

# N8N_USER_FOLDER=/files is set in the Railway service env (state: /files/.n8n).
# DB + encryption key + webhook URL also come from service env — no build args.

EXPOSE 5678

# Railway sets $PORT; n8n reads N8N_PORT. Export at runtime, not build time.
CMD export N8N_PORT=$PORT && n8n start
