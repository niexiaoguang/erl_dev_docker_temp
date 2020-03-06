# Build stage 0
FROM erlang:22.2.8-alpine

RUN apk update
RUN apk add ca-certificates && update-ca-certificates
# Change TimeZone
RUN apk add --update tzdata
ENV TZ=Asia/Shanghai
# Clean APK cache
RUN rm -rf /var/cache/apk/*

# Set working directory
RUN mkdir /buildroot
WORKDIR /buildroot

# Copy our Erlang test application
COPY cowboy_rabbit_start cowboy_rabbit_start

# And build the release
WORKDIR /cowboy_rabbit_start
RUN rebar3 as prod release

# Build stage 1
FROM alpine

# Install some libs
RUN apk add --no-cache openssl && 
    apk add --no-cache ncurses-libs

# Install the released application
COPY --from=0 /buildroot/cowboy_rabbit_start/_build/prod/rel/cowboy_rabbit_start /cowboy_rabbit_start

# Expose relevant ports
EXPOSE 8080

CMD ["/cowboy_rabbit_start/bin/cowboy_rabbit_start", "foreground"]
