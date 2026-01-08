# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
swift build        # Build the package
swift test         # Run all tests
make lint          # Run SwiftLint
make format        # Run SwiftFormat
```

## Architecture

ARCNetworking is a Swift networking library using async/await with a **Builder -> Client -> Service** layered architecture:

### Protocols (`Sources/ARCNetworking/Protocols/`)

- **Endpoint** - Protocol with associated `Response: Decodable` type defining request components
- **HTTPClientProtocol** - Defines HTTP client execution capabilities
- **RequestBuilderProtocol** - Defines URL request building capabilities
- **ARCNetworkServiceProtocol** - Defines high-level network service interface

### Implementations (`Sources/ARCNetworking/Implementations/`)

- **HTTPClient** - Executes requests via `URLSession` with async/await
- **RequestBuilder** - Transforms `Endpoint` into `URLRequest`
- **ARCNetworkService** - High-level wrapper for dependency injection

### Models (`Sources/ARCNetworking/Models/`)

- **HTTPMethod** - Enum for HTTP methods (GET, POST, PUT, DELETE, PATCH)
- **HTTPError** - Error enum (invalidURL, requestFailed, decodingFailed, unknown)
- **HTTPStatusCode** - Constants for HTTP status codes and ranges

### Dependencies

- **ARCLogger** - Structured logging library from ARC Labs Studio

## Key Conventions

- **Protocol-first design**: Every implementation has a corresponding protocol with `Sendable` conformance
- **Constructor injection**: Dependencies passed as init parameters with sensible defaults
- **Swift 6 strict concurrency**: All code must pass strict concurrency checking
- **Swift Testing framework**: Tests use `@Suite`, `@Test` attributes with `.serialized` trait for stateful tests
- **Test helpers**: `makeSUT()` factory pattern, `MockURLProtocol` for deterministic network responses
- **DocC documentation**: All public APIs must have comprehensive documentation comments

## Platform Requirements

iOS 17.0+ | macOS 14.0+ | tvOS 17.0+ | watchOS 10.0+ | Swift 6.0+
