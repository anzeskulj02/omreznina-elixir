# Use an Elixir image
FROM elixir:1.14-alpine

# Install Node.js, npm, and Git
RUN apk add --no-cache nodejs npm git

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set the working directory and copy the files
WORKDIR /app
COPY . /app

# Set the SECRET_KEY_BASE
ENV SECRET_KEY_BASE="p6OFlSpJT7C8oCSRpSHTMV6WzgmQpgwrbPoNAJzHIsixMnyLQ/r/fi7oLl61SjLu"

# Install dependencies
RUN mix deps.get --only prod

# Build assets
RUN MIX_ENV=prod mix assets.deploy

# Compile the project
RUN MIX_ENV=prod mix compile

# Set up release
RUN MIX_ENV=prod mix release

# Expose the application port
EXPOSE 4000

# Run the app
CMD ["_build/prod/rel/smart_home/bin/smart_home", "start"]
