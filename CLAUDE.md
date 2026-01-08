# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
swift build        # Build the package
swift test         # Run all tests
```

## Architecture

ARCNetworking is a Swift networking library using async/await with a **Builder → Client → Service** layered architecture:

### Core Layer (`Sources/ARCNetworking/Core/`)
- **Endpoint** - Protocol with associated `Response: Decodable` type defining request components (baseURL, path, method, headers, queryItems, body)
- **RequestBuilder** - Transforms `Endpoint` into `URLRequest`
- **HTTPClient** - Executes requests via `URLSession` with async/await
- **HTTPError** - Error enum (invalidURL, requestFailed, decodingFailed, unknown)

### Service Layer (`Sources/ARCNetworking/Services/`)
- **ARCNetworkService** - High-level wrapper for dependency injection, accepts `HTTPClientProtocol`

### Dependencies
- **ARCLogger** - Structured logging library from ARC Labs Studio

## Key Conventions

- **Protocol-first design**: Every implementation has a corresponding protocol (HTTPClientProtocol, RequestBuilderProtocol, ARCNetworkServiceProtocol)
- **Constructor injection**: Dependencies passed as init parameters with sensible defaults
- **Swift 6 strict concurrency**: All code must pass strict concurrency checking
- **Swift Testing framework**: Tests use `@Suite`, `@Test` attributes with `.serialized` trait for stateful tests
- **Test helpers**: `makeSUT()` factory pattern, `MockURLProtocol` for deterministic network responses

## Platform Requirements

iOS 14.0+ | macOS 11.0+ | tvOS 14.0+ | watchOS 7.0+ | Swift 6.0+
