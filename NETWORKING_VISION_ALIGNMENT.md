# ARCNetworking — Swift Networking Vision Alignment

This document describes how ARCNetworking aligns with the broader Swift community's vision
for unified, modern HTTP networking, and what steps we're taking incrementally.

---

## What we adopt today

### `swift-http-types` (Apple open-source, adopted in v2.0)

`swift-http-types` provides type-safe HTTP primitives (`HTTPRequest`, `HTTPResponse`,
`HTTPFields`, `HTTPField`) that form the foundation of Apple's proposed unified HTTP stack.

**How ARCNetworking uses it:**

- `Endpoint.httpFields: HTTPFields?` — conformers can opt in to type-safe header construction
- `RequestBuilder` uses `URLRequest(httpRequest:)` from `HTTPTypesFoundation` when `httpFields` is non-nil
- `HTTPMethod` raw values map directly to `HTTPRequest.Method(rawValue:)`

**Why not full migration yet:**

`swift-http-types` defines the data model but doesn't replace `URLSession` as the transport.
The `HTTPTypesFoundation` bridge (`URLRequest(httpRequest:)`) is what makes today's adoption
practical: we keep `URLSession` as the transport while gaining type-safe header semantics.

---

## What we're waiting for

### Swift unified HTTP client stack

Apple and the Swift community are converging on a unified HTTP client that spans
`Network.framework`, `Foundation`, and `swift-http-types`. The end state is a single,
cross-platform HTTP API with:

- `swift-http-types` as the universal data model (headers, methods, status)
- `Network.framework` primitives for connection management
- Removal of the historical `CFNetwork` / `NSURLSession` legacy layer

**ARCNetworking's migration path:**

When the unified client API stabilises and ships, the transport in `HTTPClient` can be
replaced without changing any public API surface — the `RequestInterceptor` chain and
`Endpoint` protocol remain stable.

The `// TODO: Migrate to Swift unified HTTP client when available` comment in
`HTTPClient` marks the single integration point.

---

## Why URLSession remains the transport

1. **Stability** — `URLSession` is production-proven across all Apple platforms
2. **Bridge exists** — `HTTPTypesFoundation` (part of `swift-http-types`) bridges between
   `swift-http-types` data types and `URLSession`/`URLRequest` with no overhead
3. **Streaming** — `URLSession.bytes(for:)` (iOS 15+) provides `AsyncBytes` for SSE
4. **Test infrastructure** — `URLProtocol` subclassing enables deterministic test mocks

---

## Backwards compatibility guarantees

| Consumer code | Status in v2.0 |
|---|---|
| `HTTPClient()` with no arguments | Identical behaviour — `[LoggingInterceptor()]` default |
| `Endpoint` with only `headers: [String: String]?` | Compiles unchanged |
| `ARCNetworkService(client:)` | No API changes |
| `MockHTTPClient: HTTPClientProtocol` | No changes needed — `stream()` has a default impl |

---

## References

- [apple/swift-http-types](https://github.com/apple/swift-http-types)
- [SE-0451 — `swift-http-types` standard library pitch](https://forums.swift.org/t/pitch-stdlib-http-types/64629)
- [WWDC 2023 — What's new in privacy](https://developer.apple.com/videos/play/wwdc2023/10053/) (HTTPTypesFoundation intro)
- [Network.framework](https://developer.apple.com/documentation/network)
