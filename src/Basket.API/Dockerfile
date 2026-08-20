# Build context is the repository root:
#   docker build -f src/Basket.API/Dockerfile -t Basket.API .
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY . .
RUN dotnet restore "src/Basket.API/Basket.API.csproj" -p:NuGetAudit=false
RUN dotnet publish "src/Basket.API/Basket.API.csproj" \
    -c $BUILD_CONFIGURATION \
    -o /app/publish \
    -p:NuGetAudit=false \
    --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
COPY --from=build /app/publish .
COPY src/Basket.API/docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh
USER $APP_UID
ENTRYPOINT ["/app/docker-entrypoint.sh"]
