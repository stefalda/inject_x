import 'package:inject_x/inject_x.dart';
import 'package:test/test.dart';

// Sample classes for testing
class TestClass1 {
  final String value = 'test1';
}

class TestClass2 {
  final int value = 42;
}

class TestClass3 {
  final bool value = true;
}

class DisposableClass {
  bool disposed = false;
  void dispose() {
    disposed = true;
  }
}

class ThrowingDisposableClass {
  void dispose() {
    throw Exception('Disposal error');
  }
}

void main() {
  group('InjectX', () {
    setUp(() {
      // Clear all instances before each test
      InjectX.clear();
    });

    test('should add and retrieve an instance correctly', () {
      final instance = TestClass1();
      InjectX.add<TestClass1>(instance);

      final retrieved = InjectX.get<TestClass1>();
      expect(retrieved, equals(instance));
      expect(retrieved.value, equals('test1'));
    });

    test('should handle multiple different types', () {
      final instance1 = TestClass1();
      final instance2 = TestClass2();

      InjectX.add<TestClass1>(instance1);
      InjectX.add<TestClass2>(instance2);

      expect(InjectX.get<TestClass1>(), equals(instance1));
      expect(InjectX.get<TestClass2>(), equals(instance2));
      expect(InjectX.length, equals(2));
    });

    test('should maintain singleton instance', () {
      final instance = TestClass1();
      InjectX.add<TestClass1>(instance);

      final retrieved1 = InjectX.get<TestClass1>();
      final retrieved2 = InjectX.get<TestClass1>();

      expect(identical(retrieved1, retrieved2), isTrue);
    });

    test('should throw StateError through get function for non-existent type',
        () {
      expect(() => InjectX.get<TestClass3>(), throwsA(isA<StateError>()));
    });

    test('should not add duplicate type', () {
      final instance1 = TestClass1();
      final instance2 = TestClass1();

      InjectX.add<TestClass1>(instance1);
      InjectX.add<TestClass1>(instance2);

      expect(InjectX.get<TestClass1>(), equals(instance1));
      expect(InjectX.length, equals(1));
    });

    test('length should reflect number of registered instances', () {
      expect(InjectX.length, equals(0));

      InjectX.add<TestClass1>(TestClass1());
      expect(InjectX.length, equals(1));

      InjectX.add<TestClass2>(TestClass2());
      expect(InjectX.length, equals(2));

      InjectX.add<TestClass1>(
          TestClass1()); // Duplicate, shouldn't increase length
      expect(InjectX.length, equals(2));
    });

    group('inject function', () {
      test('should retrieve instance through inject function', () {
        final instance = TestClass1();
        InjectX.add<TestClass1>(instance);

        final retrieved = inject<TestClass1>();
        expect(retrieved, equals(instance));
      });

      test(
          'should throw StateError through inject function for non-existent type',
          () {
        expect(() => inject<TestClass1>(), throwsA(isA<StateError>()));
      });
    });
  });

  group('InjectX.remove', () {
    test('should remove instance from registry', () {
      final instance = TestClass1();
      InjectX.add<TestClass1>(instance);
      expect(InjectX.length, equals(1));

      InjectX.remove<TestClass1>();
      expect(InjectX.length, equals(0));
      expect(() => InjectX.get<TestClass1>(), throwsA(isA<StateError>()));
    });

    test('should call dispose if method exists', () {
      final instance = DisposableClass();
      InjectX.add<DisposableClass>(instance);

      InjectX.remove<DisposableClass>();
      expect(instance.disposed, isTrue);
    });

    test('should handle non-disposable instances gracefully', () {
      final instance = TestClass1();
      InjectX.add<TestClass1>(instance);

      // Should not throw error when trying to dispose
      expect(() => InjectX.remove<TestClass1>(), returnsNormally);
    });

    test('should handle disposal errors gracefully', () {
      final instance = ThrowingDisposableClass();
      InjectX.add<ThrowingDisposableClass>(instance);

      // Should not throw error even if dispose throws
      expect(() => InjectX.remove<ThrowingDisposableClass>(), returnsNormally);
      expect(InjectX.length, equals(0));
    });

    test('should throw StateError when removing non-existent instance', () {
      expect(() => InjectX.remove<TestClass1>(), throwsA(isA<StateError>()));
    });

    test('should remove instance even if dispose throws', () {
      final instance = ThrowingDisposableClass();
      InjectX.add<ThrowingDisposableClass>(instance);
      expect(InjectX.length, equals(1));

      InjectX.remove<ThrowingDisposableClass>();
      expect(InjectX.length, equals(0));
    });
  });
}
