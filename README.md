# Test submit and redirect workflow

Expose a root page at / that renders a styled HTML form, a /success page, and a POST endpoint at /submit that accepts JSON or form data and redirects to /test with a 303 "See Other" response after a successful submission.

The app is a PSGI app (app.psgi) using Dancer2, with HTML pages rendered via send_as html and JSON content returned explicitly for the app root when needed.

```shell
docker compose up
```

Visit [http://localhost:3000/]

## POST JSON

```shell
curl -X POST -H "Content-Type: application/json" -d '{"name":"Alice"}' http://localhost:3000/submit
```
