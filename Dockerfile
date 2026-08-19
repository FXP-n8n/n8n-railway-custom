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
# NOTE: official image base (n8nio/base, Docker Hardened Images Alpine) ships NO
# package manager and NO shell — deps or shell wrappers cannot be added at build
# or run time. If ever needed, copy binaries from an alpine stage (both musl).
FROM docker.io/n8nio/n8n:2.35.3

# Previous image ran as root and all volume files under /files are root-owned;
# the official image defaults to user 'node'. Keep root to avoid EACCES on the
# existing /files volume contents.
USER root

# N8N_USER_FOLDER=/files is set in the Railway service env (state: /files/.n8n).
# DB + encryption key + webhook URL also come from service env — no build args.

EXPOSE 5678

# IMPORTANT: base image has NO shell (hardened Alpine). CMD must be exec-form,
# no "sh -c". Railway's $PORT is not available at build time; n8n's default
# listen port is 5678. Railway's n8n template convention: set N8N_PORT in the
# service env if it ever differs from 5678.
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["n8n", "start"]
