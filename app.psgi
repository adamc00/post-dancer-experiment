use strict;
use warnings;
use Dancer2;

set serializer => 'JSON';

# Health-check
get '/' => sub { { status => 'running' } };

# Accept POSTs with JSON or form data at /submit
post '/submit' => sub {
    # request->data returns parsed JSON (when content-type is application/json)
    my $data = request->data // {};

    # Echo back what we received for easy testing
    return {
        status   => 'ok',
        received => $data,
    };
};

dance;
