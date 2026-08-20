extension radius

resource pack 'Radius.Core/recipePacks@2025-08-01-preview' = {
  name: 'eshop-custom-types-v3'
  properties: {
    recipes: {
      'Radius.Resources/azureServiceBusNamespaces': {
        kind: 'bicep'
        source: 'ghcr.io/reshrahim/eshoponazure/azureservicebusnamespaces-recipe:0.1.0'
      }
    }
  }
}
