# n8n — official Docker image, no extra OS deps.
# Migration 2026-08-19: node:22-alpine + npm install -g n8n@latest  →  docker.io/n8nio/n8n
# Reasons: npm install method deprecated in n8n 3.0; official image is the
# supported self-hosting path; pinning the tag gives controlled upgrades and
# a real rollback path.
#
# Dropped apk deps (verified unused 2026-08-19 against all 154 workflows in DB):
#   - graphicsmagick: zero references in any workflow
#   - poppler-utils (pdftoppm): only user was "QC Drawing Measurement Extractor"
#     (inactive since 2026-05-27, zero executions recorded)
#   - tzdata: node bundles full ICU; TZ not set on this service
# NOTE: official image base (n8nio/base) ships NO package manager — deps cannot
# be added at build time anyway. If a dep is ever needed, copy binaries from an
# alpine stage (both musl) or use N8N_CUSTOM_EXTENSIONS/env-based alternatives.
FROM docker.io/n8nio/n8n:2.35.3

# Previous image ran as root and all volume files under /files are root-owned;
# the official image defaults to user 'node'. Keep root to avoid EACCES on the
# existing /files volume contents.
USER root

# N8N_USER_FOLDER=/files is set in the Railway service env (state: /files/.n8n).
# DB + encryption key + webhook URL also come from service env — no build args.

EXPOSE 5678

# Railway sets $PORT at runtime; n8n reads N8N_PORT.
CMD ["sh", "-c", "export N8N_PORT=$PORT && exec n8n start"]
