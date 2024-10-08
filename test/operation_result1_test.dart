import 'package:operation_result/operation_result.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  group('operation_result1', () {
    test('should return success', () {
      final result = success1(10);

      expect(result.successful, isTrue);
      expect(result.failed, isFalse);
      expect(result.hasError<Failure1>(), isFalse);
      expect(result.value, 10);
      result.ensureSuccess();

      final mapped = result.map((val) => 'val: $val');
      expect(mapped.successful, isTrue);
      expect(mapped.failed, isFalse);
      expect(mapped.hasError<Failure1>(), isFalse);
      expect(mapped.value, "val: 10");

      final forwarded = result.forward1(success: (val) => 'val: $val');
      expect(forwarded.successful, isTrue);
      expect(forwarded.failed, isFalse);
      expect(forwarded.hasError<Failure1>(), isFalse);
      expect(forwarded.value, "val: 10");
    });

    test('should return failure', () {
      final Result<int, Errors1<Failure1>> result = failure1(Failure1('error'));

      expect(result.successful, isFalse);
      expect(result.failed, isTrue);
      expect(result.hasError<Failure1>(), isTrue);
      expect(result.getError<Failure1>(), isNotNull);
      expect(result.getError<Failure1>()!.message, 'error');
      expect(result.hasSingleError<Failure1>(), isTrue);
      expect(result.hasError<UnspecifiedFailure>(), isFalse);
    });

    test('should return multiple failures', () {
      final Result<int, Errors1<Failure1>> result = failures1([Failure1('error1'), Failure1('error2')]);

      expect(result.successful, isFalse);
      expect(result.failed, isTrue);
      expect(result.hasError<Failure1>(), isTrue);
      expect(result.hasError<UnspecifiedFailure>(), isFalse);
      expect(result.getErrors<Failure1>(), hasLength(2));
      expect(result.hasSingleError<Failure1>(), isFalse);

      final mapped = result.map((val) => val.toString());

      expect(mapped.successful, isFalse);
      expect(mapped.failed, isTrue);
      expect(mapped.hasError<Failure1>(), isTrue);
      expect(mapped.hasError<UnspecifiedFailure>(), isFalse);
      expect(mapped.getErrors<Failure1>(), hasLength(2));
      expect(mapped.hasSingleError<Failure1>(), isFalse);
    });

    test('forward failed result', () {
      final result = failure1(Failure1('error'));

      final forwarded = result.forward1(failure: (e) => e);

      expect(forwarded.successful, isFalse);
      expect(forwarded.failed, isTrue);
      expect(forwarded.hasError<Failure1>(), isTrue);
      expect(forwarded.getError<Failure1>(), isNotNull);
      expect(forwarded.getError<Failure1>()!.message, 'error');
      expect(forwarded.hasSingleError<Failure1>(), isTrue);
      expect(forwarded.hasError<UnspecifiedFailure>(), isFalse);
    });

    test('ensureSuccess should throw error on failure', () {
      final result = failure1(Failure1('error'));

      expect(() => result.ensureSuccess(), throwsA(isA<AssertionError>()));
    });

    test('forward unspecified error', () {
      Result<int, Errors1<Failure1>> testFunc() {
        final result = failure1(UnspecifiedFailure('error'));
        return result.forward1(failure: (e) => e);
      }

      expect(() => testFunc(), throwsA(isA<AssertionError>()));
    });

    test('both failure and success parameters missed for forward1 function', () {
      final result = failure1(Failure1('error'));

      expect(() {
        return result.forward1();
      }, throwsA(isA<AssertionError>()));
    });

    test('failure parameter missed for forward1 function in case of operation failure', () {
      Result<int, Errors1<Failure1>> testFunc() {
        final result = failure1(UnspecifiedFailure('error'));
        return result.forward1(success: (val) => val);
      }

      expect(() => testFunc(), throwsA(isA<AssertionError>()));
    });

    test('forward failure on resultObjectWithIncorrectState()', () {
      final result = resultObjectWithIncorrectState();

      expect(() {
        return result.forward1(failure: (e) => e);
      }, throwsA(isA<AssertionError>()));
    });

    test('success parameter missed for forward function in case of operation success', () {
      final result = success1(10);

      expect(() {
        return result.forward1(failure: (e) => e);
      }, throwsA(isA<AssertionError>()));
    });
  });

  group('Result', () {
    test('Unexpected error', () {
      expect(() => Result.error([UnspecifiedFailure('err')], Errors1<Failure1>()), throwsA(isA<AssertionError>()));
    });
  });
}
