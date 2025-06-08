# InjectX

A lightweight, easy-to-use service locator implementation for Dart applications. This package provides a simple dependency injection container that helps manage application dependencies with minimal setup.

## Features

- Simple registration and retrieval of dependencies
- Singleton instance management
- Automatic disposal of services
- Type-safe dependency injection
- Angular-style `inject` function
- Zero external dependencies

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  inject_x: ^0.0.5
```

## Usage

### Basic Usage

```dart
// Register your dependencies
InjectX.add<UserService>(UserService());
InjectX.add<AuthService>(AuthService());

// Retrieve instances
final userService = InjectX.get<UserService>();
final authService = InjectX.get<AuthService>();

// Alternatively, use Angular-style injection
final userService = inject<UserService>();
```

### Init Method

If your class defines an `init()` method, it will be called automatically **before the first injection**. This is useful when your service depends on other services that need to be resolved after construction — particularly in cases of circular dependencies.

```dart
class UserService {
  late AuthService authService;

  void init() {
    authService = inject<AuthService>();
  }
}
```

The `init()` method is called **only once**, just before the first access via `get()` or `inject()`.

### Async Init Method

If your class has an `async` `init()` method (returning a `Future`), you can use `injectAsync<T>()` or `InjectX.getAsync<T>()` to ensure initialization is awaited before use.

```dart
class ConfigService {
  String? config;

  Future<void> init() async {
    await Future.delayed(Duration(milliseconds: 100));
    config = 'loaded';
  }
}

void main() async {
  InjectX.add(ConfigService());
  final config = await injectAsync<ConfigService>();
}
```

### Automatic Disposal

InjectX automatically calls a service’s `dispose()` method if it exists when the service is removed:

```dart
class DatabaseService {
  void dispose() {
    // Cleanup resources
  }
}

// Register the service
InjectX.add<DatabaseService>(DatabaseService());

// Later, remove it
InjectX.remove<DatabaseService>(); // dispose() will be called automatically
```

## API Reference

### Methods

- `add<T>(T instance)`: Register a new dependency
- `get<T>()`: Retrieve a registered dependency, calling `init()` if defined
- `getAsync<T>()`: Retrieve a registered dependency, awaiting `init()` if it's async
- `remove<T>()`: Remove a registered dependency and call `dispose()` if defined
- `length`: The number of registered dependencies
- `clear()`: Remove all dependencies and dispose each (if supported)

### Helper Functions

- `inject<T>()`: Angular-style helper to call `InjectX.get<T>()`
- `injectAsync<T>()`: Angular-style helper for services with async `init()`

## Error Handling

The package includes error handling for common scenarios:

```dart
// Attempting to retrieve a non-existent dependency
try {
  final service = InjectX.get<UnregisteredService>();
} catch (e) {
  // Throws StateError: No instance registered for type UnregisteredService
}
```

## Best Practices

1. Register all dependencies early in your app lifecycle
2. Use meaningful type parameters for clarity
3. Implement `dispose()` for services that require cleanup
4. Remove services when no longer needed (e.g., on module unload)

## Example

```dart
class UserService {
  void dispose() {
    // Cleanup
  }
}

class AuthService {
  final UserService userService;

  AuthService(this.userService);
}

void main() {
  // Register services
  InjectX.add<UserService>(UserService());

  // Register a dependent service
  InjectX.add<AuthService>(AuthService(inject<UserService>()));

  // Use services
  final userService = inject<UserService>();
  final authService = inject<AuthService>();

  // Cleanup
  InjectX.remove<AuthService>();
  InjectX.remove<UserService>();
}
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request.  
For major changes, open an issue first to discuss what you'd like to propose.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
