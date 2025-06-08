/// Singleton of all injectable classes
class InjectX {
  InjectX._();
  static final Map<Type, dynamic> _instances = Map();
  // Holds the name of the class already initialized by calling the init method
  static final Set<Type> _initializedInstances = Set();
  // Prevents multiple calls to async init
  static final Map<Type, Future<void>> _pendingInit = {};

  /// Add the instance and return it so it can be assigned
  static T add<T>(T instance) {
    _instances.putIfAbsent(T, () => instance);
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
    _instances.remove(T);
    _initializedInstances.remove(T);
  }

  static void _checkRegistered<T>() {
    if (!_instances.containsKey(T)) {
      throw StateError('No instance registered for type ${T.toString()}. '
          'Make sure to register it using InjectX.add<${T.toString()}>() first.');
    }
  }

  /// Return the class or instantiate it if it's missing
  /// calls the init method for deferred initialition if it's not be called
  static T get<T>() {
    _checkRegistered<T>();
    // If it's the first time and the init method has not be called try to call it.
    if (!_initializedInstances.contains(T)) {
      try {
        _initializedInstances.add(T);
        (_instances[T] as dynamic).init();
      } catch (_) {
        // Method doesn't exist or isn't callable
        print(
            'Info: ${T.toString()} has no init() method (just to let you know).');
      }
    }
    return _instances[T];
  }

  static Future<T> getAsync<T>() async {
    _checkRegistered<T>();

    final instance = _instances[T];

    // Await if init is already in progress
    if (_pendingInit.containsKey(T)) {
      await _pendingInit[T];
      return instance;
    }

    // Check if not yet initialized
    if (!_initializedInstances.contains(T)) {
      final dynamic obj = instance;

      if (obj.init is Function) {
        final result = obj.init();
        if (result is Future) {
          _pendingInit[T] = result;
          await result;
          _pendingInit.remove(T);
        }
      }

      _initializedInstances.add(T);
    }

    return instance;
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
    _initializedInstances.clear();
    _pendingInit.clear();
  }
}

/// Angular style
T inject<T>() {
  return InjectX.get<T>();
}

/// Angular style async
Future<T> injectAsync<T>() {
  return InjectX.getAsync<T>();
}
