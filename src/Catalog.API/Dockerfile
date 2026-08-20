# Build context is the repository root:
#   docker build -f src/Catalog.API/Dockerfile -t Catalog.API .
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY . .
RUN dotnet restore "src/Catalog.API/Catalog.API.csproj" -p:NuGetAudit=false
RUN dotnet publish "src/Catalog.API/Catalog.API.csproj" \
    -c $BUILD_CONFIGURATION \
    -o /app/publish \
    -p:NuGetAudit=false \
    --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
COPY --from=build /app/publish .
USER $APP_UID
ENTRYPOINT ["dotnet", "Catalog.API.dll"]
