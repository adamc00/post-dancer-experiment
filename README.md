Dockerized Dancer2 app

This repository contains a minimal Dancer2 application packaged in Docker. It exposes a POST endpoint at /submit that accepts JSON or form-encoded data and echoes it back.

Build and run with Docker:

  # Build image
  docker build -t dancer-app .

  # Run container
  docker run --rm -p 3000:3000 dancer-app

Or with Docker Compose (modern CLI: "docker compose"):

  docker compose up --build
  # or, if using the legacy docker-compose binary:
  # docker-compose up --build

Notes:
- The included compose.yaml uses the modern Compose spec (no top-level "version" key), adds a healthcheck, restart policy, and a development bind-mount. Remove the bind-mount in production if you want the container to use the image's filesystem only.

Test the endpoint:

  # Health-check
  curl http://localhost:3000/

  # POST JSON
  curl -X POST -H "Content-Type: application/json" -d '{"name":"Alice"}' http://localhost:3000/submit

The app is a PSGI app (app.psgi) and uses Dancer2 with JSON serializer.
