# ExampleApp

Demo application for ARCNetworking.

## Requirements

- Xcode 16.0+
- iOS 17.0+

## Running the Example

1. Open `ExampleApp/ExampleApp.xcodeproj` in Xcode
2. The package is referenced locally from the parent directory
3. Select a simulator and press Run (⌘R)

## Features Demonstrated

- **Endpoint Protocol**: Defining type-safe API endpoints with `PostsEndpoint` and `PostEndpoint`
- **ARCNetworkService**: Using the high-level network service for HTTP requests
- **Async/Await**: Modern Swift concurrency patterns for network calls
- **Error Handling**: Displaying loading states and error messages

## Project Structure

```
ExampleApp/
├── ExampleApp.swift          # App entry point
├── Models/
│   └── Post.swift            # Data model
├── Networking/
│   └── PostsEndpoint.swift   # API endpoint definitions
├── Views/
│   ├── ContentView.swift     # Main list view
│   ├── PostRowView.swift     # List row component
│   └── PostDetailView.swift  # Detail view
└── Assets.xcassets/          # App assets
```

## API Used

This example uses [JSONPlaceholder](https://jsonplaceholder.typicode.com), a free fake API for testing and prototyping.
