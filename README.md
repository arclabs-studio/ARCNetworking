# 🕸️ ARCNetworking

A modern, modular, and type-safe networking layer built with Swift Concurrency.  
Designed for scalability, reusability, and clean architecture across multiple iOS apps.

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platform](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-blue.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)
![Xcode](https://img.shields.io/badge/Xcode-15%2B-blue.svg)

---

## ✨ Features

- ✅ Built with **Swift Concurrency** (`async/await`)
- 🧱 Clean architecture: **Builder → Client → Service**
- 🧩 Fully **protocol-oriented** and **testable**
- 🪵 Structured logging via **os.Logger**
- 🧠 Modular, reusable, and dependency-injectable
- 🧪 Includes **Swift Testing** test suite

---

## 🛠️ Requirements

| Platform | Minimum |
|-----------|----------|
| iOS | 14.0 |
| macOS | 11.0 |
| tvOS | 14.0 |
| watchOS | 7.0 |
| Swift | 6.0+ |
| Xcode | 15+ |

---

## 📦 Installation

You can add **ARCNetworking** as a dependency using **Swift Package Manager**.

In your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/carlosrasensio/ARCNetworking.git", from: "0.1.0")
]

