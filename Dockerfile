FROM node:24-slim AS builder
WORKDIR /app
RUN mkdir -p config
COPY . .

ARG CI=true
ENV CI=${CI}

# Se CI=true, il build è già stato fatto nel workflow; altrimenti compilare qui
RUN if [ "$CI" != "true" ]; then \
      corepack enable && corepack prepare pnpm@latest --activate && \
      pnpm install --frozen-lockfile && \
      pnpm build; \
    else \
      echo "✅ Using prebuilt app from CI"; \
    fi

FROM node:24-alpine AS runner
WORKDIR /app

COPY --link --chown=1000:1000 /public ./public/
COPY --link --chown=1000:1000 .next/standalone ./
COPY --link --chown=1000:1000 .next/static ./.next/static
COPY --link --chmod=755 docker-entrypoint.sh /usr/local/bin/

RUN apk add --no-cache su-exec iputils-ping shadow

USER root
ENV NODE_ENV=production
ENV HOSTNAME=::
ENV PORT=3000
EXPOSE $PORT

HEALTHCHECK --interval=10s --timeout=3s --start-period=20s \
  CMD wget --no-verbose --tries=1 --spider -Y off http://127.0.0.1:$PORT/api/healthcheck || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "server.js"]
