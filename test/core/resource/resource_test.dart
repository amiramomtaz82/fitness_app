import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const failure = NetworkFailure(serverMessage: 'no internet');

  group('Resource constructors', () {
    test('initial carries no data, no failure and reports isInitial', () {
      const resource = Resource<String>.initial();
      expect(resource.status, ApiStatus.initial);
      expect(resource.data, isNull);
      expect(resource.failure, isNull);
      expect(resource.isInitial, isTrue);
      expect(resource.isLoading, isFalse);
      expect(resource.isSuccess, isFalse);
      expect(resource.isError, isFalse);
    });

    test('loading reports isLoading and no failure', () {
      const resource = Resource<String>.loading();
      expect(resource.status, ApiStatus.loading);
      expect(resource.isLoading, isTrue);
      expect(resource.failure, isNull);
    });

    test('success carries data and reports isSuccess', () {
      const resource = Resource<String>.success('payload');
      expect(resource.status, ApiStatus.success);
      expect(resource.data, 'payload');
      expect(resource.isSuccess, isTrue);
    });

    test('error carries the failure and reports isError', () {
      const resource = Resource<String>.error(failure);
      expect(resource.status, ApiStatus.error);
      expect(resource.failure, failure);
      expect(resource.isError, isTrue);
    });
  });

  group('Resource equality', () {
    test('resources with the same status, data and failure are equal', () {
      const a = Resource<String>.success('payload');
      const b = Resource<String>.success('payload');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different data or status breaks equality', () {
      const a = Resource<String>.success('payload');
      const b = Resource<String>.success('other');
      const c = Resource<String>.loading();
      expect(a, isNot(b));
      expect(a, isNot(c));
    });
  });
}
