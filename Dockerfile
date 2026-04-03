FROM node:20-slim AS builder

# Install Bun
RUN npm install -g bun@1.3.11

WORKDIR /app

# Install dependencies (cached layer)
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Build
COPY . .
RUN bun run build

# ── Runtime image ──────────────────────────────────────────────────────────────
FROM node:20-slim

WORKDIR /app
COPY --from=builder /app/dist/cli.mjs ./dist/cli.mjs
COPY --from=builder /app/bin/openclaude ./bin/openclaude

# Projects mount here — only this directory is accessible to the agent
WORKDIR /workspace

ENTRYPOINT ["node", "/app/dist/cli.mjs"]
