#!/bin/sh
set -e

# Radius' redisCaches recipe publishes the cache credentials as a single URL
# (rediss://:<access-key>@<host>:<port>). StackExchange.Redis, which Basket.API
# uses via AddRedisClient, does not parse URL-form connection strings, so
# translate REDIS_URL into the configuration-string form it expects.
if [ -n "$REDIS_URL" ]; then
    scheme="${REDIS_URL%%://*}"
    rest="${REDIS_URL#*://}"

    case "$rest" in
        *@*)
            credentials="${rest%@*}"
            hostport="${rest##*@}"
            ;;
        *)
            credentials=""
            hostport="$rest"
            ;;
    esac

    hostport="${hostport%%/*}"
    password="${credentials#*:}"

    if [ "$scheme" = "rediss" ]; then
        ssl="True"
    else
        ssl="False"
    fi

    if [ -n "$password" ]; then
        ConnectionStrings__Redis="${hostport},ssl=${ssl},password=${password},abortConnect=False"
    else
        ConnectionStrings__Redis="${hostport},ssl=${ssl},abortConnect=False"
    fi

    export ConnectionStrings__Redis
fi

exec dotnet Basket.API.dll "$@"
