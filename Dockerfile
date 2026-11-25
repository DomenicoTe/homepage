FROM node:24-slim AS builder
WORKDIR /app
RUN mkdir -p config
COPY . .

FROM node:24-alpine AS runner
WORKDIR /app

COPY --link --chown=1000:1000 /public ./public/
COPY --link --chmod=755 docker-entrypoint.sh /usr/local/bin/

COPY --link --from=builder --chown=1000:1000 /app/.next/standalone/ ./
COPY --link --from=builder --chown=1000:1000 /app/.next/static/ ./.next/static

RUN apk add --no-cache su-exec iputils-ping shadow
USER ROOT
ENV NODE_ENV=production
ENV HOSTNAME=::
ENV PORT=3000
HEALTHCHECK --interval=10s --timeout=3s --start-period=20s \
  CMD wget --no-verbose --tries=1 --spider -Y off http://127.0.0.1:$PORT/api/healthcheck || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "server.js"]

