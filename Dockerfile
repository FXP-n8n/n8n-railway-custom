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
#
# Base image notes (n8nio/base = Docker Hardened Images Alpine):
#   - NO package manager, NO shell in the default exec path.
#   - Railway's runtime execs the start command without resolving /usr/local/bin,
#     so ALL commands below use absolute paths.
FROM docker.io/n8nio/n8n:2.35.3

# Previous image ran as root and all volume files under /files are root-owned;
# the official image defaults to user 'node'. Keep root to avoid EACCES on the
# existing /files volume contents.
USER root

# Railway injects PORT=8080; n8n listens on N8N_PORT. No shell exists at start
# time to map one to the other, so pin it (PORT is stable on this service).
ENV N8N_PORT=8080

# N8N_USER_FOLDER=/files is set in the Railway service env (state: /files/.n8n).
# DB + encryption key + webhook URL also come from service env — no build args.

EXPOSE 8080

# Skip /docker-entrypoint.sh (it needs /bin/sh): its only feature we'd lose is
# optional custom-cert loading from /opt/custom-certificates, which we don't use.
# tini is the image's init; n8n binary is symlinked at /usr/local/bin/n8n.
ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/n8n", "start"]
