# Test submit and redirect workflow

Expose a root page at `/` that renders a HTML form, a `/success` page, and a `POST` endpoint at `/submit` that accepts JSON or form data and redirects to `/success` with a 303 "See Other" response on success. Test post data is included in the redirect URL.

The app is a PSGI app (app.psgi) using Dancer2.

```shell
docker compose up
```

Visit <http://localhost:3000/>

## POST JSON

```shell
curl -X POST -H "Content-Type: application/json" -d '{"name":"Alice"}' http://localhost:3000/submit
```
