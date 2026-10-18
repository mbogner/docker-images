# https://github.com/kosuvorov/VoicePrompter - no releases, build from pinned upstream commit.
# When bumping the commit, check that all patches in patches/ still apply.
ARG VOICEPROMPTER_COMMIT=99e08a0586fda9c3226c48207c787d6214a2e2a5

FROM node:26-alpine AS builder
ARG VOICEPROMPTER_COMMIT
RUN apk add --no-cache git
WORKDIR /src
RUN git init -q . \
    && git remote add origin https://github.com/kosuvorov/VoicePrompter.git \
    && git fetch -q --depth 1 origin ${VOICEPROMPTER_COMMIT} \
    && git checkout -q FETCH_HEAD
COPY patches/ /patches/
RUN for p in /patches/*.patch; do [ -e "$p" ] || continue; git apply --verbose "$p" || exit 1; done
RUN npm ci && npm run build

FROM node:26-alpine
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"
ARG VOICEPROMPTER_COMMIT
ENV VOICEPROMPTER_COMMIT=${VOICEPROMPTER_COMMIT} \
    NODE_ENV=production
RUN npm install -g serve@14 && npm cache clean --force
WORKDIR /app
COPY --from=builder --chown=node:node /src/dist/ ./
USER node
EXPOSE 3000
CMD ["serve", "--no-clipboard", "--listen", "tcp://0.0.0.0:3000", "/app"]
