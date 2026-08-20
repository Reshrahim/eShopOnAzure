# Build context is the repository root:
#   docker build -f src/PaymentProcessor/Dockerfile -t PaymentProcessor .
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY . .
RUN dotnet restore "src/PaymentProcessor/PaymentProcessor.csproj"
RUN dotnet publish "src/PaymentProcessor/PaymentProcessor.csproj" \
    -c $BUILD_CONFIGURATION \
    -o /app/publish \
    --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
COPY --from=build /app/publish .
USER $APP_UID
ENTRYPOINT ["dotnet", "PaymentProcessor.dll"]
