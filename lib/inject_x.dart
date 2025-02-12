/// Singleton of all injectable classes
class InjectX {
  InjectX._();
  static final Map _instances = Map();

  /// Add the instance and return it so it can be assigned
  static T add<T>(T instance) {
    _instances.putIfAbsent(T.toString(), () => instance);
    return instance;
  }

  /// Remove the instance
  static void remove<T>() {
    final instance = get<T>();
    try {
      (instance as dynamic).dispose();
    } catch (_) {
      // Method doesn't exist or isn't callable
    }
    _instances.remove(T.toString());
  }

  /// Return the class or instantiate it if it's missing
  static T get<T>() {
    if (!_instances.containsKey(T.toString())) {
      throw StateError('No instance registered for type ${T.toString()}. '
          'Make sure to register it using InjectX.add<${T.toString()}>() first.');
    }
    return _instances[T.toString()];
  }

  static int get length {
    return _instances.length;
  }

  /// Remove all instances
  ///
  static clear() {
    // Call dispose on each class
    for (dynamic instance in _instances.values) {
      try {
        (instance as dynamic).dispose();
      } catch (_) {
        // Method doesn't exist or isn't callable
      }
    }
    _instances.clear();
  }
}

/// Angular style
T inject<T>() {
  return InjectX.get<T>();
}
