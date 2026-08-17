FROM perl:5.36-slim

ENV PLACK_ENV production

# Install build tools and cpanminus
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        cpanminus \
        libssl-dev \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Perl module dependencies declared in cpanfile
COPY cpanfile /app/
RUN cpanm --quiet --notest --installdeps .

EXPOSE 3000

CMD ["plackup", "-p", "3000", "-o", "0.0.0.0", "app.psgi"]
