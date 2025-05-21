# InjectX

A lightweight, easy-to-use service locator pattern implementation for Dart applications. This package provides a simple dependency injection container that helps manage application dependencies with minimal setup.

## Features

- Simple registration and retrieval of dependencies
- Singleton instance management
- Automatic disposal of services
- Type-safe dependency injection
- Angular-style inject function
- Zero external dependencies

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  inject_x: ^0.0.3
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

// Alternative Angular-style injection
final userService = inject<UserService>();
```

### Automatic Disposal

The InjectX automatically handles disposal of services that implement a `dispose` method:

```dart
class DatabaseService {
  void dispose() {
    // Cleanup resources
  }
}

// Register the service
final dbService = InjectX.add<DatabaseService>(DatabaseService());

// Later, when removing the service
InjectX.remove<DatabaseService>(); // dispose() will be called automatically
```

## API Reference

### Methods

- `add<T>(T instance)`: Register a new dependency
- `get<T>()`: Retrieve a registered dependency
- `remove<T>()`: Remove a registered dependency and dispose if applicable
- `length`: Get the number of registered dependencies
- `clear`: Remove all registered dependencies performing dispose on each one (if supported)

### Helper Functions

- `T inject<T>()`: Angular-style dependency injection helper

## Error Handling

The package includes proper error handling for common scenarios:

```dart
// Attempting to retrieve non-existent dependency
try {
  final service = InjectX.get<UnregisteredService>();
} catch (e) {
  // Throws StateError: No instance registered for type UnregisteredService
}
```

## Best Practices

1. Register dependencies early in your application lifecycle
2. Use meaningful type parameters for better code clarity
3. Implement dispose methods for services that need cleanup
4. Remove services when they're no longer needed

## Example

Here's a complete example showing various features:

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
  final userService = InjectX.add<UserService>(UserService());
  
  // Create dependent service
  final authService = AuthService(inject<UserService>());
  InjectX.add<AuthService>(authService);
  
  // Use services
  final users = inject<UserService>();
  final auth = inject<AuthService>();
  
  // Cleanup
  InjectX.remove<AuthService>();
  InjectX.remove<UserService>();
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details.