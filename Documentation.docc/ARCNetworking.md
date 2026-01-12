# ``ARCNetworking``

A modern, modular, and type-safe networking layer built with Swift Concurrency.

@Metadata {
    @PageColor(blue)
}

## Overview

ARCNetworking provides a clean, protocol-oriented networking layer for Apple platforms. Built with Swift 6 strict concurrency compliance, it offers a layered **Builder → Client → Service** architecture that promotes testability and separation of concerns.

The framework centers around the ``Endpoint`` protocol, which defines all components of a network request. The ``RequestBuilder`` transforms endpoints into `URLRequest` objects, while ``HTTPClient`` handles execution via `URLSession`. ``ARCNetworkService`` provides a high-level interface for dependency injection.

### Quick Start

Define an endpoint by conforming to ``Endpoint``:

```swift
struct GetUserEndpoint: Endpoint {
    typealias Response = User

    var baseURL: URL { URL(string: "https://api.example.com")! }
    var path: String { "users/\(userId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }

    let userId: String
}
```

Execute the request using ``ARCNetworkService``:

```swift
let service = ARCNetworkService()
let user = try await service.request(GetUserEndpoint(userId: "123"))
```

## Topics

### Essentials

- ``Endpoint``
- ``ARCNetworkService``
- ``HTTPError``

### Building Requests

- ``RequestBuilder``
- ``RequestBuilderProtocol``
- ``HTTPMethod``

### Executing Requests

- ``HTTPClient``
- ``HTTPClientProtocol``
- ``HTTPStatusCode``

### Service Layer

- ``ARCNetworkServiceProtocol``
