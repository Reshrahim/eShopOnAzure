extension radius
extension customTypes

param environment string

@secure()
param postgresPassword string

param azureAdTenantId string

param azureAdClientId string

@secure()
param azureAdClientSecret string

@secure()
param registryUsername string

@secure()
param registryPassword string

resource eshopApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'eshop-on-azure'
  properties: {
    environment: environment
  }
}

resource catalogPostgresDb 'Radius.Data/postgreSqlDatabases@2025-08-01-preview' = {
  name: 'catalogdb'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Catalog.API/Extensions/Extensions.cs#L9'
    database: 'catalogdb'
    username: 'eshopadmin'
    password: postgresPassword
  }
}

resource orderingPostgresDb 'Radius.Data/postgreSqlDatabases@2025-08-01-preview' = {
  name: 'orderingdb'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Ordering.API/Extensions/Extensions.cs#L17'
    database: 'orderingdb'
    username: 'eshopadmin'
    password: postgresPassword
  }
}

resource webhooksPostgresDb 'Radius.Data/postgreSqlDatabases@2025-08-01-preview' = {
  name: 'webhooksdb'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Webhooks.API/Extensions/Extensions.cs#L12'
    database: 'webhooksdb'
    username: 'eshopadmin'
    password: postgresPassword
  }
}

resource redisCache 'Radius.Data/redisCaches@2025-08-01-preview' = {
  name: 'redis'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Basket.API/Extensions/Extensions.cs#L15'
  }
}

resource eventBus 'Radius.Resources/azureServiceBusNamespaces@2025-08-01-preview' = {
  name: 'event-bus'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/EventBusServiceBus/ServiceBusDependencyInjectionExtensions.cs#L19'
    topic: 'eshop_event_bus'
    sku: 'Standard'
  }
}

resource registryCreds 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: eshopApp.id
    data: {
      username: {
        value: registryUsername
      }
      password: {
        value: registryPassword
      }
    }
  }
}

resource catalogImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'catalog-api-image'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Catalog.API/Dockerfile'
    build: {
      source: 'git::https://github.com/Reshrahim/eShopOnAzure.git?ref=63434b3fe417635dae2e29b36203b978739d3353'
      dockerfile: 'src/Catalog.API/Dockerfile'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource basketImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'basket-api-image'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Basket.API/Dockerfile'
    build: {
      source: 'git::https://github.com/Reshrahim/eShopOnAzure.git?ref=63434b3fe417635dae2e29b36203b978739d3353'
      dockerfile: 'src/Basket.API/Dockerfile'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource orderingImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'ordering-api-image'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Ordering.API/Dockerfile'
    build: {
      source: 'git::https://github.com/Reshrahim/eShopOnAzure.git?ref=63434b3fe417635dae2e29b36203b978739d3353'
      dockerfile: 'src/Ordering.API/Dockerfile'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource orderProcessorImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'order-processor-image'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/OrderProcessor/Dockerfile'
    build: {
      source: 'git::https://github.com/Reshrahim/eShopOnAzure.git?ref=63434b3fe417635dae2e29b36203b978739d3353'
      dockerfile: 'src/OrderProcessor/Dockerfile'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource paymentProcessorImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'payment-processor-image'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/PaymentProcessor/Dockerfile'
    build: {
      source: 'git::https://github.com/Reshrahim/eShopOnAzure.git?ref=63434b3fe417635dae2e29b36203b978739d3353'
      dockerfile: 'src/PaymentProcessor/Dockerfile'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource webhooksImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'webhooks-api-image'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Webhooks.API/Dockerfile'
    build: {
      source: 'git::https://github.com/Reshrahim/eShopOnAzure.git?ref=63434b3fe417635dae2e29b36203b978739d3353'
      dockerfile: 'src/Webhooks.API/Dockerfile'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource mobileBffImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'mobile-bff-image'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Mobile.Bff.Shopping/Dockerfile'
    build: {
      source: 'git::https://github.com/Reshrahim/eShopOnAzure.git?ref=63434b3fe417635dae2e29b36203b978739d3353'
      dockerfile: 'src/Mobile.Bff.Shopping/Dockerfile'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource webhooksClientImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'webhooks-client-image'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/WebhookClient/Dockerfile'
    build: {
      source: 'git::https://github.com/Reshrahim/eShopOnAzure.git?ref=63434b3fe417635dae2e29b36203b978739d3353'
      dockerfile: 'src/WebhookClient/Dockerfile'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource webappImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'webapp-image'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/WebApp/Dockerfile'
    build: {
      source: 'git::https://github.com/Reshrahim/eShopOnAzure.git?ref=63434b3fe417635dae2e29b36203b978739d3353'
      dockerfile: 'src/WebApp/Dockerfile'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource catalogApi 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'catalog-api'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Catalog.API/Program.cs#L3'
    containers: {
      catalog: {
        image: catalogImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
        env: {
          POSTGRES_PASSWORD: {
            value: postgresPassword
          }
          ConnectionStrings__catalogdb: {
            value: 'Host=${catalogPostgresDb.properties.host};Port=5432;Database=catalogdb;Username=eshopadmin;Password=${postgresPassword};SSL Mode=Require;Trust Server Certificate=true'
          }
          ConnectionStrings__eventBus: {
            valueFrom: {
              secretKeyRef: {
                secretName: eventBus.properties.secrets.name
                key: 'connectionString'
              }
            }
          }
          EventBus__SubscriptionClientName: {
            value: 'Catalog'
          }
        }
      }
    }
    connections: {
      catalogdb: {
        source: catalogPostgresDb.id
      }
      eventbus: {
        source: eventBus.id
      }
    }
  }
}

resource basketApi 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'basket-api'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Basket.API/Program.cs#L3'
    containers: {
      basket: {
        image: basketImage.properties.imageReference
        ports: {
          grpc: {
            containerPort: 8080
          }
        }
        env: {
          REDIS_URL: {
            valueFrom: {
              secretKeyRef: {
                secretName: redisCache.properties.secrets.name
                key: 'url'
              }
            }
          }
          ConnectionStrings__eventBus: {
            valueFrom: {
              secretKeyRef: {
                secretName: eventBus.properties.secrets.name
                key: 'connectionString'
              }
            }
          }
          EventBus__SubscriptionClientName: {
            value: 'Basket'
          }
          AzureAd__TenantId: {
            value: azureAdTenantId
          }
          AzureAd__ClientId: {
            value: azureAdClientId
          }
        }
      }
    }
    connections: {
      rediscache: {
        source: redisCache.id
      }
      eventbus: {
        source: eventBus.id
      }
    }
  }
}

resource orderingApi 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'ordering-api'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Ordering.API/Program.cs#L3'
    containers: {
      ordering: {
        image: orderingImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
        env: {
          POSTGRES_PASSWORD: {
            value: postgresPassword
          }
          ConnectionStrings__orderingdb: {
            value: 'Host=${orderingPostgresDb.properties.host};Port=5432;Database=orderingdb;Username=eshopadmin;Password=${postgresPassword};SSL Mode=Require;Trust Server Certificate=true'
          }
          ConnectionStrings__eventBus: {
            valueFrom: {
              secretKeyRef: {
                secretName: eventBus.properties.secrets.name
                key: 'connectionString'
              }
            }
          }
          EventBus__SubscriptionClientName: {
            value: 'Ordering'
          }
          AzureAd__TenantId: {
            value: azureAdTenantId
          }
          AzureAd__ClientId: {
            value: azureAdClientId
          }
        }
      }
    }
    connections: {
      orderingdb: {
        source: orderingPostgresDb.id
      }
      eventbus: {
        source: eventBus.id
      }
    }
  }
}

resource orderProcessor 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'order-processor'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/OrderProcessor/Program.cs#L1'
    containers: {
      orderProcessor: {
        image: orderProcessorImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
        env: {
          POSTGRES_PASSWORD: {
            value: postgresPassword
          }
          ConnectionStrings__orderingdb: {
            value: 'Host=${orderingPostgresDb.properties.host};Port=5432;Database=orderingdb;Username=eshopadmin;Password=${postgresPassword};SSL Mode=Require;Trust Server Certificate=true'
          }
          ConnectionStrings__eventBus: {
            valueFrom: {
              secretKeyRef: {
                secretName: eventBus.properties.secrets.name
                key: 'connectionString'
              }
            }
          }
          EventBus__SubscriptionClientName: {
            value: 'OrderProcessor'
          }
        }
      }
    }
    connections: {
      orderingdb: {
        source: orderingPostgresDb.id
      }
      eventbus: {
        source: eventBus.id
      }
    }
  }
}

resource paymentProcessor 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'payment-processor'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/PaymentProcessor/Program.cs#L3'
    containers: {
      paymentProcessor: {
        image: paymentProcessorImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
        env: {
          ConnectionStrings__EventBus: {
            valueFrom: {
              secretKeyRef: {
                secretName: eventBus.properties.secrets.name
                key: 'connectionString'
              }
            }
          }
          EventBus__SubscriptionClientName: {
            value: 'PaymentProcessor'
          }
        }
      }
    }
    connections: {
      eventbus: {
        source: eventBus.id
      }
    }
  }
}

resource webhooksApi 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'webhooks-api'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Webhooks.API/Program.cs#L3'
    containers: {
      webhooks: {
        image: webhooksImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
        env: {
          POSTGRES_PASSWORD: {
            value: postgresPassword
          }
          ConnectionStrings__webhooksdb: {
            value: 'Host=${webhooksPostgresDb.properties.host};Port=5432;Database=webhooksdb;Username=eshopadmin;Password=${postgresPassword};SSL Mode=Require;Trust Server Certificate=true'
          }
          ConnectionStrings__eventBus: {
            valueFrom: {
              secretKeyRef: {
                secretName: eventBus.properties.secrets.name
                key: 'connectionString'
              }
            }
          }
          EventBus__SubscriptionClientName: {
            value: 'Webhooks'
          }
          AzureAd__TenantId: {
            value: azureAdTenantId
          }
          AzureAd__ClientId: {
            value: azureAdClientId
          }
        }
      }
    }
    connections: {
      webhooksdb: {
        source: webhooksPostgresDb.id
      }
      eventbus: {
        source: eventBus.id
      }
    }
  }
}

resource mobileBff 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'mobile-bff'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/Mobile.Bff.Shopping/Program.cs#L1'
    containers: {
      mobileBff: {
        image: mobileBffImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
        env: {
          'services__catalog-api__http__0': {
            value: 'http://${catalogApi.properties.hosts.catalog}:8080'
          }
          'services__ordering-api__http__0': {
            value: 'http://${orderingApi.properties.hosts.ordering}:8080'
          }
        }
      }
    }
    connections: {
      catalogapi: {
        source: catalogApi.id
      }
      orderingapi: {
        source: orderingApi.id
      }
    }
  }
}

resource webhooksClient 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'webhooks-client'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/WebhookClient/Program.cs#L1'
    containers: {
      webhooksClient: {
        image: webhooksClientImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
        env: {
          'services__webhooks-api__http__0': {
            value: 'http://${webhooksApi.properties.hosts.webhooks}:8080'
          }
          AzureAd__TenantId: {
            value: azureAdTenantId
          }
          AzureAd__ClientId: {
            value: azureAdClientId
          }
          AzureAd__ClientSecret: {
            value: azureAdClientSecret
          }
        }
      }
    }
    connections: {
      webhooksapi: {
        source: webhooksApi.id
      }
    }
  }
}

resource webapp 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'webapp'
  properties: {
    environment: environment
    application: eshopApp.id
    codeReference: 'src/WebApp/Program.cs#L4'
    containers: {
      webapp: {
        image: webappImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
        env: {
          'services__basket-api__http__0': {
            value: 'http://${basketApi.properties.hosts.basket}:8080'
          }
          'services__catalog-api__http__0': {
            value: 'http://${catalogApi.properties.hosts.catalog}:8080'
          }
          'services__ordering-api__http__0': {
            value: 'http://${orderingApi.properties.hosts.ordering}:8080'
          }
          ConnectionStrings__EventBus: {
            valueFrom: {
              secretKeyRef: {
                secretName: eventBus.properties.secrets.name
                key: 'connectionString'
              }
            }
          }
          EventBus__SubscriptionClientName: {
            value: 'Ordering.webapp'
          }
          AzureAd__TenantId: {
            value: azureAdTenantId
          }
          AzureAd__ClientId: {
            value: azureAdClientId
          }
          AzureAd__ClientSecret: {
            value: azureAdClientSecret
          }
        }
      }
    }
    connections: {
      eventbus: {
        source: eventBus.id
      }
      basketapi: {
        source: basketApi.id
      }
      catalogapi: {
        source: catalogApi.id
      }
      orderingapi: {
        source: orderingApi.id
      }
    }
  }
}
