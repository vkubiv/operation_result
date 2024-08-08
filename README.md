## Why an other implementation of Result pattern?

This package arise from the need to specify expected errors from API calls and handle them in a more convenient way. 
Original workaround was to use comments on function signature:
    
```dart
// Throws Unauthorized, InvalidFormField
Future<Profile> editProfile(EditProfile editProfile) async
```
But comments are not checked neither by compiler nor on runtime. So they become outdated and not reliable.

With operation_result package errors can be specified in the next way:

```dart
AsyncResult<Profile, Errors2<Unauthorized, InvalidFormField>> editProfile(
    EditProfile editProfile) async
```

## Usage

Example show how operation_result can be used to handle API errors. 

```dart

AsyncResult<Response, Errors2<Unauthorized, ValidationError>> httpPost(String path,
    Object data) async {
  ...
  if (success) {
    return success2(response);
  }

  if (code == 401) {
    return failure2(Unauthorized());
  }

  if (code == 400) {
  final errors = readErrorsJson(response);
      // Result can contains multiple errors.
      return failures2(errors.map((e) => ValidationError.fromMap(e)));
  }
}

AsyncResult<AuthToken, Errors2<InvalidCredentials, EmailNotConfirmed>> login(String login,
    String password) async {
  final response = await httpPost('/auth/login', {'login': login, 'password': password});
  return response.forward2(
      success: (r) => AuthToken.parse(r.data),
      failure: (e) =>
      switch (e) {
        (ValidationError e) when e.code == 'email-not-confirmed' => EmailNotConfirmed(),
        (Unauthorized) => InvalidCredentials(),
        _ => e
      });
}

AsyncResult<Profile, Errors2<Unauthorized, InvalidFormField>> editProfile(
    EditProfile editProfile) async {
  final response = await httpPost('/profile/edit', editProfile.toMap());
  return response.forward2(
    success: (response) => Profile.fromMap(response.data),
    failure: (e) =>
    switch (e) {
      (Unauthorized e) => e,
      (ValidationError e) when e.code == 'incorrect-value' =>
          InvalidFormField(fieldName: e.incorrectValue, message: e.message),
      _ => e
    },
  );
}

// Login screen
void onLoginPressed() async {
  final loginResult = await login('login', 'password');
  if (loginResult.hasError<InvalidCredentials>()) {
    form.setFailure(['Password or email are incorrect']);
    return;
  }

  if (loginResult.hasError<EmailNotConfirmed>()) {
    router.redirectToConfirmationPage();
    return;
  }

  authStorage.storeToken(loginResult.value);
  router.goToHomePage();
}


// Profile screen
void onEditProfilePressed() async {
  final editResult = await editProfile(editProfile);
  if (editResult.hasError<Unauthorized>()) {
    router.redirectToLoginPage();
    return;
  }

  final filedErrors = editResult.getErrors<InvalidFormField>();
  if (filedErrors.isNotEmpty) {
    for (final filedError in filedErrors) {
      form.setError(filedError.fieldName, filedError.message);
    }
    return;
  }

  if (editResult.failed) {
    form.setFailure(['Unhandled errors: ${editResult.errors}']);
    return;
  }

  form.setSuccess();
}

```

## What is package is not meant to be used for?

This package don't have a goal to replace exceptions as generic errors handling mechanism in Dart.
It is tailored for specific use case of "expected" errors, where usage of exceptions is not convenient.

## Limitations and drawbacks

* Dart generics do not supports variadic parameters, so you need to use specific types like `Errors2`, `Errors3` etc.
And corresponding function like `forward2`, `forward3`, `success2`, `failure2` etc.

* Most of checks are done on runtime.