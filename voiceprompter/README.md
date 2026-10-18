# VoicePrompter

[VoicePrompter](https://github.com/kosuvorov/VoicePrompter) voice-controlled teleprompter, built from source and served
as static site with [serve](https://github.com/vercel/serve) on node alpine.

The upstream commit is pinned in the `Dockerfile` (`VOICEPROMPTER_COMMIT`). All `patches/*.patch` files are applied in
filename order with `git apply` before the build. Image tag = short upstream commit hash + number of patches, e.g.
`99e08a0-p2`.

Current patches:

- `0001`: start directly with the app - `/` redirects to `/app/`, marketing start page and back-link removed
- `0002`: remove the "Try native app" promo card from the settings panel
- `0003`: fix upstream startup crash `Cannot access '...' before initialization` - `dockPinned` was declared after the
  synchronous `boot()` call

To create a new patch, clone upstream, check out the pinned commit, apply the existing patches with `git am patches/*.patch`,
commit your change and export it with `git format-patch -1 -o <this-dir>/patches/`. When bumping the pinned commit, check
that all patches still apply.

Voice control uses the browser's Web Speech API and microphone, which only work in a secure context. Access the app via
`localhost` or put it behind a reverse proxy with TLS.

## Docker Compose

You can use docker-compose to start the container. Create a file named docker-compose.yml and run docker compose up -d
in the same directory. -d will detach your command and won't require your shell to stay open.

```yaml
services:
  voiceprompter:
    image: mbopm/voiceprompter:latest
    ports:
      - "127.0.0.1:3000:3000"
```

The app itself is available under http://localhost:3000/app/

----------

- docker hub: https://hub.docker.com/repository/docker/mbopm/voiceprompter
- git: https://github.com/mbogner/docker-images
