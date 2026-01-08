# ARCNetworking

A modern, modular, and type-safe networking layer built with Swift Concurrency.
Designed for scalability, reusability, and clean architecture across Apple platform apps.

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platform](https://img.shields.io/badge/platforms-iOS%2017%2B%20%7C%20macOS%2014%2B%20%7C%20tvOS%2017%2B%20%7C%20watchOS%2010%2B-blue.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)
![Xcode](https://img.shields.io/badge/Xcode-16%2B-blue.svg)

---

## Features

- Built with **Swift Concurrency** (`async/await`)
- Clean architecture: **Builder -> Client -> Service**
- Fully **protocol-oriented** and **testable**
- Structured logging via **ARCLogger**
- **Swift 6 strict concurrency** compliant
- Modular, reusable, and dependency-injectable
- Includes **Swift Testing** test suite

---

## Requirements

| Platform  | Minimum |
|-----------|---------|
| iOS       | 17.0    |
| macOS     | 14.0    |
| tvOS      | 17.0    |
| watchOS   | 10.0    |
| Swift     | 6.0+    |
| Xcode     | 16+     |

---

## Installation

Add **ARCNetworking** as a dependency using **Swift Package Manager**.

In your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arclabs-studio/ARCNetworking.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "ARCNetworking", package: "ARCNetworking")
    ]
)
```

---

## Quick Start

### 1. Define an Endpoint

```swift
import ARCNetworking

struct GetUserEndpoint: Endpoint {
    typealias Response = User

    var baseURL: URL { URL(string: "https://api.example.com")! }
    var path: String { "users/\(userId)" }
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { ["Authorization": "Bearer \(token)"] }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }

    let userId: String
    let token: String
}

struct User: Decodable {
    let id: String
    let name: String
    let email: String
}
```

### 2. Make a Request

```swift
import ARCNetworking

let service = ARCNetworkService()

do {
    let user = try await service.request(
        GetUserEndpoint(userId: "123", token: "your-token")
    )
    print("User: \(user.name)")
} catch let error as HTTPError {
    print("Request failed: \(error.localizedDescription)")
}
```

---

## Architecture

ARCNetworking follows a **Builder -> Client -> Service** layered architecture:

```
Sources/ARCNetworking/
├── Protocols/           # Abstractions
│   ├── Endpoint.swift
│   ├── HTTPClientProtocol.swift
│   ├── RequestBuilderProtocol.swift
│   └── ARCNetworkServiceProtocol.swift
├── Implementations/     # Concrete types
│   ├── HTTPClient.swift
│   ├── RequestBuilder.swift
│   └── ARCNetworkService.swift
└── Models/              # Data types
    ├── HTTPMethod.swift
    ├── HTTPError.swift
    └── HTTPStatusCode.swift
```

### Components

| Component | Responsibility |
|-----------|----------------|
| **Endpoint** | Protocol defining request components (URL, method, headers, body) |
| **RequestBuilder** | Transforms `Endpoint` into `URLRequest` |
| **HTTPClient** | Executes requests via `URLSession` with async/await |
| **ARCNetworkService** | High-level wrapper for dependency injection |

---

## Error Handling

ARCNetworking provides structured error handling via `HTTPError`:

```swift
public enum HTTPError: Error {
    case invalidURL
    case requestFailed(Int)      // HTTP status code
    case decodingFailed(Error)   // JSON decoding error
    case unknown(Error)          // Other errors
}
```

Usage:

```swift
do {
    let response = try await service.request(endpoint)
} catch HTTPError.requestFailed(let statusCode) {
    print("Server returned \(statusCode)")
} catch HTTPError.decodingFailed(let error) {
    print("Failed to parse response: \(error)")
} catch {
    print("Unexpected error: \(error)")
}
```

---

## Testing

ARCNetworking is designed for testability. All components use protocol-based dependency injection:

```swift
// Create a mock client
final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    var mockResponse: Any?
    var mockError: Error?

    func execute<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        if let error = mockError { throw error }
        return mockResponse as! T.Response
    }
}

// Inject into service
let mockClient = MockHTTPClient()
mockClient.mockResponse = User(id: "1", name: "Test", email: "test@example.com")

let service = ARCNetworkService(client: mockClient)
let user = try await service.request(GetUserEndpoint(userId: "1", token: ""))
```

---

## Dependencies

- [ARCLogger](https://github.com/arclabs-studio/ARCLogger) - Structured logging library

---

## Documentation

Full API documentation is available via DocC.

---

## License

MIT License - see [LICENSE](LICENSE) file.

---

## Author

**ARC Labs Studio**
