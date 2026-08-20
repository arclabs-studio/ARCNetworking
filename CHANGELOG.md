# Changelog

All notable changes to ARCNetworking will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-20

First public release of **ARCNetworking**.

ARC Labs Studio re-baselined every package at `1.0.0` for its first product launch. The pre-launch version history (0.1.0 → 1.0.0) never corresponded to a release the studio stood behind; those tags and GitHub Releases have been removed and the notes are preserved below under [Pre-1.0 history](#pre-10-history-untagged).

### Added

- **`INTERNAL-USE.md`** — documents ARC Labs Studio's self-grant for commercial use of its own products under the new licence.

- `swift-http-types` integration: `Endpoint.httpFields: HTTPFields?` extension (type-safe headers via `HTTPTypesFoundation`)
- Composable `RequestInterceptor` middleware protocol for request/response pipeline
- `AuthenticationInterceptor` — injects Bearer tokens from any async provider (Firebase Auth, Keychain, etc.)
- `RetryInterceptor` — exponential backoff retry on HTTP 5xx with injectable sleep for testability
- `LoggingInterceptor` — structured logging via ARCLogger (`#if DEBUG` gated)
- SSE/streaming support: `HTTPClientProtocol.stream(_:) -> AsyncThrowingStream<Data, Error>`

### Changed

- `HTTPClient.init` now accepts `interceptors: [any RequestInterceptor]` (default: `[LoggingInterceptor()]`, preserving v1.0 logging behaviour)
- Inline logging in `HTTPClient` moved to `LoggingInterceptor`
- `RequestBuilder` now uses `HTTPTypesFoundation` bridge when `endpoint.httpFields` is non-nil; falls back to legacy `headers: [String: String]?` path

- **License** — relicensed from MIT to [PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0). Source-available and free for non-commercial use; commercial use requires a separate licence from ARC Labs Studio. ARC Labs Studio's own products are covered by an internal grant — see `INTERNAL-USE.md`.

---

## Pre-1.0 history (untagged)

Everything below predates the 1.0.0 baseline. The version numbers are retained for traceability only — no tag or release exists for any of them.

### [1.0.0] - 2026-01-08

#### Added

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

#### Changed

- Minimum platform requirements: iOS 17+, macOS 14+, tvOS 17+, watchOS 10+
- Reorganized package structure following ARCKnowledge standards:
  - `Protocols/` - All protocol definitions
  - `Implementations/` - Concrete implementations
  - `Models/` - Data types and enums

---

### [0.1.0] - 2025-10-24

#### Added

- Initial development version
- Basic networking layer with async/await support
- Prototype implementations for internal testing

---

[1.0.0]: https://github.com/arclabs-studio/ARCNetworking/releases/tag/v1.0.0
