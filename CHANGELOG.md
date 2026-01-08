# Changelog

All notable changes to ARCNetworking will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-01-08

### Added

- Initial stable release of ARCNetworking
- `Endpoint` protocol for type-safe API endpoint definitions
- `HTTPClient` for executing network requests with async/await
- `RequestBuilder` for transforming endpoints into URLRequests
- `ARCNetworkService` as high-level networking abstraction
- `HTTPError` enum with comprehensive error cases
- `HTTPMethod` enum supporting GET, POST, PUT, DELETE, PATCH
- `HTTPStatusCode` constants for status code validation
- Full Swift 6 strict concurrency support
- Protocol-first design with `Sendable` conformance
- Configurable `JSONDecoder` injection
- Integration with ARCLogger for structured logging
- Comprehensive test suite using Swift Testing framework

### Changed

- Minimum platform requirements: iOS 17+, macOS 14+, tvOS 17+, watchOS 10+
- Reorganized package structure following ARCKnowledge standards:
  - `Protocols/` - All protocol definitions
  - `Implementations/` - Concrete implementations
  - `Models/` - Data types and enums

## [0.1.0] - 2025-10-24

### Added

- Initial development version
- Basic networking layer with async/await support
- Prototype implementations for internal testing
