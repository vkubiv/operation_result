/// Example of usage:
/// ```dart
/// AsyncResult<AuthToken, Errors2<InvalidCredentials, EmailNotConfirmed>> login(String login, String password) {
///  ...
/// }
///
/// final loginResult = await login('login', 'password');
/// if (loginResult.hasError<InvalidCredentials>()) {
///   formStatus.setFailure(['Password or email are incorrect'.localize]);
///   return;
/// }
///
/// if (loginResult.hasError<EmailNotConfirmed>()) {
///  router.redirectToConfirmationPage();
///  return;
/// }
/// authStorage.storeToken(loginResult.value);
/// router.goToHomePage();
///
/// ```
class Result<T, Errors extends IExpectedErrors> {
  /// List of errors that happened during operation.
  final Iterable<Object> errors;

  /// Get error of specific type, returns null if no such error.
  E? getError<E extends Object>() => errors.whereType<E>().firstOrNull;

  /// Get all errors of specific type.
  Iterable<E> getErrors<E extends Object>() => errors.whereType<E>();

  /// Check if there is a single error of specific type.
  bool hasSingleError<E extends Object>() => errors.length == 1 && errors.whereType<E>().length == 1;

  /// Check if operation failed with specific error.
  bool hasError<E extends Object>() => errors.whereType<E>().isNotEmpty;

  /// Returns true if operation was successful.
  bool get successful => errors.isEmpty;

  /// Returns true if operation failed.
  bool get failed => !successful;

  /// Return result of successful operation, if operation failed throws AssertionError with list of unexpected errors.
  T get value {
    ensureSuccess();

    return _data as T;
  }

  void ensureSuccess() {
    if (failed) {
      throw AssertionError('Unhandled expected errors: \n\n$errors');
    }
  }

  /// Creates successful result.
  Result.success(this._data, this._expectedErrors) : errors = const [];

  /// Creates failed result.
  Result.error(this.errors, this._expectedErrors) : _data = null {
    final unexpected = errors.where((e) => !_expectedErrors.isExpectedError(e));
    if (unexpected.isNotEmpty) {
      throw AssertionError('Unexpected errors: $unexpected');
    }
  }

  /// Transform successful result with given function. If operation failed, returns failed result with the same errors.
  Result<U, Errors> map<U>(U Function(T) f) {
    if (_data != null) {
      return Result.success(f(_data  as T), _expectedErrors);
    } else {
      return Result.error(errors, _expectedErrors);
    }
  }

  /// Allows to forward and transform successful and failed results.
  /// If operation was successful, calls success callback and returns successful result with transformed data.
  /// If operation failed, calls failure callback for each error and returns failed result with transformed errors.
  /// Example:
  /// ```dart
  ///
  /// Errors2<Unauthorized, ValidationError> httpPost(String path, Object data) {
  ///   ...
  /// }
  ///
  /// AsyncResult<AuthToken, Errors2<InvalidCredentials, EmailNotConfirmed>> login(String login, String password) {
  ///   final response = httpPost('/auth/login', {'login': login, 'password': password});
  ///   return response.forward2(
  ///     success: (r) => AuthToken.parse(r.data),
  ///     failure: (e) => switch (e) {
  ///       ValidationError e when e.code == 'email-not-confirmed' => EmailNotConfirmed(),
  ///       Unauthorized => InvalidCredentials(),
  ///       _ => e
  ///     });
  /// }
  Result<U, Errors1<E0>> forward1<U, E0 extends Object>({
    U Function(T r)? success,
    Object Function(Object err)? failure,
  }) {
    final expected = Errors1<E0>();

    if (success == null && failure == null) {
      throw AssertionError('Either success or failure should be provided');
    }

    if (_data == null && errors.isEmpty) {
      throw AssertionError('Result object in incorrect state, should have either data or errors');
    }

    if (_data != null) {
      if (success == null) {
        throw AssertionError('Cannot forward a successful result without a success callback');
      }

      return Result.success(success(_data as T), expected);
    }

    if (errors.isNotEmpty && failure == null) {
      throw AssertionError('Cannot forward a failed result without a failure callback');
    }

    var resultingErrors = errors;
    if (failure != null) {
      resultingErrors = resultingErrors.map(failure).toList();
    }

    final unexpected = resultingErrors.where((e) => !expected.isExpectedError(e));
    if (unexpected.isNotEmpty) {
      throw AssertionError('Cannot forward an unexpected errors: $unexpected');
    }

    return Result.error(resultingErrors, expected);
  }

  /// Allows to forward and transform successful and failed results.
  /// If operation was successful, calls success callback and returns successful result with transformed data.
  /// If operation failed, calls failure callback for each error and returns failed result with transformed errors.
  /// Example:
  /// ```dart
  ///
  /// Errors2<Unauthorized, ValidationError> httpPost(String path, Object data) {
  ///   ...
  /// }
  ///
  /// AsyncResult<AuthToken, Errors2<InvalidCredentials, EmailNotConfirmed>> login(String login, String password) {
  ///   final response = httpPost('/auth/login', {'login': login, 'password': password});
  ///   return response.forward2(
  ///     success: (r) => AuthToken.parse(r.data),
  ///     failure: (e) => switch (e) {
  ///       ValidationError e when e.code == 'email-not-confirmed' => EmailNotConfirmed(),
  ///       Unauthorized => InvalidCredentials(),
  ///       _ => e
  ///     });
  /// }
  Result<U, Errors2<E0, E1>> forward2<U, E0 extends Object, E1 extends Object>({
    U Function(T r)? success,
    Object Function(Object err)? failure,
  }) {
    final expected = Errors2<E0, E1>();

    if (success == null && failure == null) {
      throw AssertionError('Either success or failure should be provided');
    }

    if (_data == null && errors.isEmpty) {
      throw AssertionError('Result object in incorrect state, should have either data or errors');
    }

    if (_data != null) {
      if (success == null) {
        throw AssertionError('Cannot forward a successful result without a success callback');
      }

      return Result.success(success(_data as T), expected);
    }

    if (errors.isNotEmpty && failure == null) {
      throw AssertionError('Cannot forward a failed result without a failure callback');
    }

    var resultingErrors = errors;
    if (failure != null) {
      resultingErrors = resultingErrors.map(failure).toList();
    }

    final unexpected = resultingErrors.where((e) => !expected.isExpectedError(e));
    if (unexpected.isNotEmpty) {
      throw AssertionError('Cannot forward an unexpected errors: $unexpected');
    }

    return Result.error(resultingErrors, expected);
  }

  /// Allows to forward and transform successful and failed results.
  /// If operation was successful, calls success callback and returns successful result with transformed data.
  /// If operation failed, calls failure callback for each error and returns failed result with transformed errors.
  Result<U, Errors3<E0, E1, E2>> forward3<U, E0 extends Object, E1 extends Object, E2 extends Object>(
      {U Function(T r)? success, Object Function(Object err)? failure}) {
    final expected = Errors3<E0, E1, E2>();

    if (success == null && failure == null) {
      throw AssertionError('Either success or failure should be provided');
    }

    if (_data == null && errors.isEmpty) {
      throw AssertionError('Result object in incorrect state, should have either data or errors');
    }

    if (_data != null) {
      if (success == null) {
        throw AssertionError('Cannot forward a successful result without a success callback');
      }

      return Result.success(success(_data as T), expected);
    }

    if (errors.isNotEmpty && failure == null) {
      throw AssertionError('Cannot forward a failed result without a failure callback');
    }

    var resultingErrors = errors;
    if (failure != null) {
      resultingErrors = resultingErrors.map(failure).toList();
    }

    final unexpected = resultingErrors.where((e) => !expected.isExpectedError(e));
    if (unexpected.isNotEmpty) {
      throw AssertionError('Cannot forward an unexpected errors: $unexpected');
    }

    return Result.error(resultingErrors, expected);
  }

  Result<U, Errors4<E0, E1, E2, E3>>
      forward4<U, E0 extends Object, E1 extends Object, E2 extends Object, E3 extends Object>(
          {U Function(T r)? success, Object Function(Object err)? failure}) {
    final expected = Errors4<E0, E1, E2, E3>();

    if (success == null && failure == null) {
      throw AssertionError('Either success or failure should be provided');
    }

    if (_data == null && errors.isEmpty) {
      throw AssertionError('Result object in incorrect state, should have either data or errors');
    }

    if (_data != null) {
      if (success == null) {
        throw AssertionError('Cannot forward a successful result without a success callback');
      }

      return Result.success(success(_data as T), expected);
    }

    if (errors.isNotEmpty && failure == null) {
      throw AssertionError('Cannot forward a failed result without a failure callback');
    }

    var resultingErrors = errors;
    if (failure != null) {
      resultingErrors = resultingErrors.map(failure).toList();
    }

    final unexpected = resultingErrors.where((e) => !expected.isExpectedError(e));
    if (unexpected.isNotEmpty) {
      throw AssertionError('Cannot forward an unexpected errors: $unexpected');
    }

    return Result.error(resultingErrors, expected);
  }

  Result<U, Errors5<E0, E1, E2, E3, E4>>
      forward5<U, E0 extends Object, E1 extends Object, E2 extends Object, E3 extends Object, E4 extends Object>(
          {U Function(T r)? success, Object Function(Object err)? failure}) {
    final expected = Errors5<E0, E1, E2, E3, E4>();

    if (success == null && failure == null) {
      throw AssertionError('Either success or failure should be provided');
    }

    if (_data == null && errors.isEmpty) {
      throw AssertionError('Result object in incorrect state, should have either data or errors');
    }

    if (_data != null) {
      if (success == null) {
        throw AssertionError('Cannot forward a successful result without a success callback');
      }

      return Result.success(success(_data as T), expected);
    }

    if (errors.isNotEmpty && failure == null) {
      throw AssertionError('Cannot forward a failed result without a failure callback');
    }

    var resultingErrors = errors;
    if (failure != null) {
      resultingErrors = resultingErrors.map(failure).toList();
    }

    final unexpected = resultingErrors.where((e) => !expected.isExpectedError(e));
    if (unexpected.isNotEmpty) {
      throw AssertionError('Cannot forward an unexpected errors: $unexpected');
    }

    return Result.error(resultingErrors, expected);
  }

  Result<U, Errors6<E0, E1, E2, E3, E4, E5>> forward6<
      U,
      E0 extends Object,
      E1 extends Object,
      E2 extends Object,
      E3 extends Object,
      E4 extends Object,
      E5 extends Object>({U Function(T r)? success, Object Function(Object err)? failure}) {
    final expected = Errors6<E0, E1, E2, E3, E4, E5>();

    if (success == null && failure == null) {
      throw AssertionError('Either success or failure should be provided');
    }

    if (_data == null && errors.isEmpty) {
      throw AssertionError('Result object in incorrect state, should have either data or errors');
    }

    if (_data != null) {
      if (success == null) {
        throw AssertionError('Cannot forward a successful result without a success callback');
      }

      return Result.success(success(_data as T), expected);
    }

    if (errors.isNotEmpty && failure == null) {
      throw AssertionError('Cannot forward a failed result without a failure callback');
    }

    var resultingErrors = errors;
    if (failure != null) {
      resultingErrors = resultingErrors.map(failure).toList();
    }

    final unexpected = resultingErrors.where((e) => !expected.isExpectedError(e));
    if (unexpected.isNotEmpty) {
      throw AssertionError('Cannot forward an unexpected errors: $unexpected');
    }

    return Result.error(resultingErrors, expected);
  }

  final IExpectedErrors _expectedErrors;
  final T? _data;
}

sealed class IExpectedErrors {
  bool isExpectedError(Object err);

  IExpectedErrors();
}

class Errors1<Expected0 extends Object> extends IExpectedErrors {
  @override
  bool isExpectedError(Object err) {
    return err is Expected0;
  }
}

class Errors2<Expected0 extends Object, Expected1 extends Object> extends IExpectedErrors {
  @override
  bool isExpectedError(Object err) {
    return err is Expected0 || err is Expected1;
  }
}

class Errors3<Expected0 extends Object, Expected1 extends Object, Expected2 extends Object> extends IExpectedErrors {
  @override
  bool isExpectedError(Object err) {
    return err is Expected0 || err is Expected1 || err is Expected2;
  }
}

class Errors4<Expected0 extends Object, Expected1 extends Object, Expected2 extends Object, Expected3 extends Object>
    extends IExpectedErrors {
  @override
  bool isExpectedError(Object err) {
    return err is Expected0 || err is Expected1 || err is Expected2 || err is Expected3;
  }
}

class Errors5<Expected0 extends Object, Expected1 extends Object, Expected2 extends Object, Expected3 extends Object,
    Expected4 extends Object> extends IExpectedErrors {
  @override
  bool isExpectedError(Object err) {
    return err is Expected0 || err is Expected1 || err is Expected2 || err is Expected3 || err is Expected4;
  }
}

class Errors6<Expected0 extends Object, Expected1 extends Object, Expected2 extends Object, Expected3 extends Object,
    Expected4 extends Object, Expected5 extends Object> extends IExpectedErrors {
  @override
  bool isExpectedError(Object err) {
    return err is Expected0 ||
        err is Expected1 ||
        err is Expected2 ||
        err is Expected3 ||
        err is Expected4 ||
        err is Expected5;
  }
}

typedef AsyncResult<T, Errors extends IExpectedErrors> = Future<Result<T, Errors>>;

Result<T, Errors1<E0>> success1<T, E0 extends Object>(T data) {
  return Result<T, Errors1<E0>>.success(data, Errors1());
}

Result<T, Errors2<E0, E1>> success2<T, E0 extends Object, E1 extends Object>(T data) {
  return Result<T, Errors2<E0, E1>>.success(data, Errors2());
}

Result<T, Errors3<E0, E1, E2>> success3<T, E0 extends Object, E1 extends Object, E2 extends Object>(T data) {
  return Result<T, Errors3<E0, E1, E2>>.success(data, Errors3());
}

Result<T, Errors4<E0, E1, E2, E3>>
    success4<T, E0 extends Object, E1 extends Object, E2 extends Object, E3 extends Object>(T data) {
  return Result<T, Errors4<E0, E1, E2, E3>>.success(data, Errors4());
}

Result<T, Errors5<E0, E1, E2, E3, E4>>
    success5<T, E0 extends Object, E1 extends Object, E2 extends Object, E3 extends Object, E4 extends Object>(T data) {
  return Result<T, Errors5<E0, E1, E2, E3, E4>>.success(data, Errors5());
}

Result<T, Errors6<E0, E1, E2, E3, E4, E5>> success6<T, E0 extends Object, E1 extends Object, E2 extends Object,
    E3 extends Object, E4 extends Object, E5 extends Object>(T data) {
  return Result<T, Errors6<E0, E1, E2, E3, E4, E5>>.success(data, Errors6());
}

Result<T, Errors1<E0>> failure1<T, E0 extends Object>(E0 err) {
  return Result<T, Errors1<E0>>.error([err], Errors1<E0>());
}

Result<T, Errors1<E0>> failures1<T, E0 extends Object>(List<E0> errors) {
  return Result<T, Errors1<E0>>.error(errors, Errors1<E0>());
}

Result<T, Errors2<E0, E1>> failure2<T, E0 extends Object, E1 extends Object>(Object err) {
  return Result<T, Errors2<E0, E1>>.error([err], Errors2<E0, E1>());
}

Result<T, Errors2<E0, E1>> failures2<T, E0 extends Object, E1 extends Object>(Iterable<Object> errors) {
  return Result<T, Errors2<E0, E1>>.error(errors, Errors2<E0, E1>());
}

Result<T, Errors3<E0, E1, E2>> failure3<T, E0 extends Object, E1 extends Object, E2 extends Object>(Object err) {
  return Result<T, Errors3<E0, E1, E2>>.error([err], Errors3<E0, E1, E2>());
}

Result<T, Errors3<E0, E1, E2>> failures3<T, E0 extends Object, E1 extends Object, E2 extends Object>(
    Iterable<Object> errors) {
  return Result<T, Errors3<E0, E1, E2>>.error(errors, Errors3<E0, E1, E2>());
}

Result<T, Errors4<E0, E1, E2, E3>>
    failure4<T, E0 extends Object, E1 extends Object, E2 extends Object, E3 extends Object>(Object err) {
  return Result<T, Errors4<E0, E1, E2, E3>>.error([err], Errors4<E0, E1, E2, E3>());
}

Result<T, Errors4<E0, E1, E2, E3>>
    failures4<T, E0 extends Object, E1 extends Object, E2 extends Object, E3 extends Object>(Iterable<Object> errors) {
  return Result<T, Errors4<E0, E1, E2, E3>>.error(errors, Errors4<E0, E1, E2, E3>());
}

Result<T, Errors5<E0, E1, E2, E3, E4>>
    failure5<T, E0 extends Object, E1 extends Object, E2 extends Object, E3 extends Object, E4 extends Object>(
        Object err) {
  return Result<T, Errors5<E0, E1, E2, E3, E4>>.error([err], Errors5<E0, E1, E2, E3, E4>());
}

Result<T, Errors5<E0, E1, E2, E3, E4>>
    failures5<T, E0 extends Object, E1 extends Object, E2 extends Object, E3 extends Object, E4 extends Object>(
        Iterable<Object> errors) {
  return Result<T, Errors5<E0, E1, E2, E3, E4>>.error(errors, Errors5<E0, E1, E2, E3, E4>());
}

Result<T, Errors6<E0, E1, E2, E3, E4, E5>> failure6<T, E0 extends Object, E1 extends Object, E2 extends Object,
    E3 extends Object, E4 extends Object, E5 extends Object>(Object err) {
  return Result<T, Errors6<E0, E1, E2, E3, E4, E5>>.error([err], Errors6<E0, E1, E2, E3, E4, E5>());
}

Result<T, Errors6<E0, E1, E2, E3, E4, E5>> failures6<T, E0 extends Object, E1 extends Object, E2 extends Object,
    E3 extends Object, E4 extends Object, E5 extends Object>(Iterable<Object> errors) {
  return Result<T, Errors6<E0, E1, E2, E3, E4, E5>>.error(errors, Errors6<E0, E1, E2, E3, E4, E5>());
}
