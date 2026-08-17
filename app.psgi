use strict;
use warnings;
use Dancer2;
use JSON::MaybeXS ();  # use fully-qualified calls to avoid prototype/import conflicts in embedded env

my $shared_css = q{
  :root {
    --bg: #0f172a;
    --panel: #111827;
    --accent: #22c55e;
    --text: #e5e7eb;
    --muted: #9ca3af;
    --button-text: #06210d;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    min-height: 100vh;
    display: grid;
    place-items: center;
    font-family: Arial, sans-serif;
    background: linear-gradient(135deg, #0f172a, #1e293b);
    color: var(--text);
  }
  .card {
    width: min(560px, 90vw);
    padding: 2rem;
    border-radius: 18px;
    background: rgba(17, 24, 39, 0.88);
    border: 1px solid rgba(34, 197, 94, 0.4);
    box-shadow: 0 18px 40px rgba(0, 0, 0, 0.35);
    text-align: center;
  }
  .badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 72px;
    height: 72px;
    border-radius: 50%;
    background: rgba(34, 197, 94, 0.14);
    color: var(--accent);
    font-size: 2.5rem;
    margin-bottom: 1rem;
  }
  h1 {
    margin: 0 0 0.5rem;
    font-size: clamp(2rem, 5vw, 3rem);
  }
  p {
    margin: 0;
    color: var(--muted);
    line-height: 1.6;
  }
  a, button {
    display: inline-block;
    margin-top: 1.5rem;
    padding: 0.85rem 1.25rem;
    border-radius: 999px;
    background: var(--accent);
    color: var(--button-text);
    text-decoration: none;
    font-weight: 700;
    border: none;
    cursor: pointer;
    font-size: 1rem;
  }
  form {
    margin-top: 1rem;
  }
};

my $render_page = sub {
    my ($title, $inner_html) = @_;
    return qq{<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>$title</title>
    <style>$shared_css</style>
  </head>
  <body>
    <main class="card">
      $inner_html
    </main>
  </body>
</html>};
};

# Simple HTML escape helper to avoid XSS when interpolating user-provided data.
my $escape_html = sub {
    my ($s) = @_;
    return '' unless defined $s;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    $s =~ s/"/&quot;/g;
    $s =~ s/'/&#39;/g;
    return $s;
};

# Root page with the HTML test form.
get '/' => sub {
    my $content = qq{
      <div class="badge">→</div>
      <h1>Submit test</h1>
      <p>Send a quick sample submission to the server.</p>
      <form action="/submit" method="post">
        <input type="text" name="name" value="test">
        <button type="submit">Submit test</button>
      </form>
    };
    return send_as html => $render_page->('Test Submit', $content);
};

# Success page for the test endpoint.
get '/success' => sub {

    my $raw_name = params->{name} // '';
    my $name = $escape_html->($raw_name);

    my $content = qq{
      <div class="badge">✓</div>
      <h1>Success!</h1>
      <p>Your test submission was accepted and redirected correctly.</p>
      <p><strong>name:</strong> $name</p>
      <p>name = $name</p>
      <a href="/">Back to form</a>
    };
    return send_as html => $render_page->('Success', $content);
};

# Accept POSTs with JSON or form data at /submit
post '/submit' => sub {
    my $data;

    if (request->content_type && request->content_type =~ /json/i) {
        my $body = request->body || '';
        if (length $body) {
            my $decoded;
            eval { $decoded = JSON::MaybeXS::decode_json($body); 1 };
            if ($@) {
                status 400;
                content_type 'application/json';
                return JSON::MaybeXS::encode_json({ error => 'invalid_json', message => "JSON parse error: $@" });
            }
            # Ensure $data is a hashref for downstream usage; if JSON is a non-object, wrap it.
            $data = (ref $decoded eq 'HASH') ? $decoded : { value => $decoded };
        } else {
            $data = {};
        }
    } else {
        $data = params() || {};
    }

    # Successful POSTs redirect to the success page as a see-other redirect.
    redirect '/success?name=' . $data->{name}, 303;
};

dance;
