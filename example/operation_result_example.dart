import 'package:operation_result/operation_result.dart';

// global variable just for simplicity of the example.
late final HttpClient client;

AsyncResult<Response, Errors2<Unauthorized, ValidationError>> httpPost(String path, Object data) async {
  final response = await client.post(path, data);

  if (response.statusCode == 200) {
    return success2(response);
  }

  if (response.statusCode == 401) {
    return failure2(Unauthorized());
  }

  if (response.statusCode == 400) {
    final List<dynamic> errors = response.data['errors'];
    return failures2(errors.map((e) => ValidationError.fromMap(e)));
  }

  throw Exception('Unexpected status code: ${response.statusCode}');
}

AsyncResult<AuthToken, Errors2<InvalidCredentials, EmailNotConfirmed>> login(String login, String password) async {
  final response = await httpPost('/auth/login', {'login': login, 'password': password});
  return response.forward2(
      success: (r) => AuthToken.parse(r.data),
      failure: (e) => switch (e) {
            (ValidationError e) when e.code == 'email-not-confirmed' => EmailNotConfirmed(),
            (Unauthorized _) => InvalidCredentials(),
            _ => e
          });
}

AsyncResult<Profile, Errors2<Unauthorized, InvalidFormField>> editProfile(Profile editProfile) async {
  final response = await httpPost('/profile/edit', editProfile.toMap());
  return response.forward2(
    success: (response) => Profile.fromMap(response.data),
    failure: (e) => switch (e) {
      (Unauthorized e) => e,
      (ValidationError e) when e.code == 'incorrect-value' =>
        InvalidFormField(fieldName: e.incorrectValue, message: e.message),
      _ => e
    },
  );
}

class LoginState {
  final Form form;
  final AuthStorage authStorage;
  final Router router;

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

  const LoginState({
    required this.form,
    required this.authStorage,
    required this.router,
  });
}

class EditProfileState {
  final Form form;
  final Router router;

  void onEditProfilePressed() async {
    final editResult = await editProfile(Profile(fistName: form.get('fistName'), lastName: form.get('lastName')));
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

  const EditProfileState({
    required this.form,
    required this.router,
  });
}

class AuthToken {
  final String token;

  AuthToken(this.token);

  factory AuthToken.parse(Map<String, dynamic> map) {
    return AuthToken(map['token']);
  }
}

class Profile {
  final String fistName;
  final String lastName;

  const Profile({
    required this.fistName,
    required this.lastName,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      fistName: map['firstName'],
      lastName: map['lastName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': fistName,
      'lastName': lastName,
    };
  }
}

class Unauthorized {
  const Unauthorized();
}

class EmailNotConfirmed {
  const EmailNotConfirmed();
}

class InvalidCredentials {
  const InvalidCredentials();
}

class InvalidFormField {
  final String fieldName;
  final String message;

  const InvalidFormField({
    required this.fieldName,
    required this.message,
  });
}

class ValidationError {
  final String code;
  final String incorrectValue;
  final String message;

  const ValidationError({
    required this.code,
    required this.incorrectValue,
    required this.message,
  });

  factory ValidationError.fromMap(Map<String, dynamic> map) {
    return ValidationError(
      code: map['code'],
      incorrectValue: map['incorrectValue'],
      message: map['message'],
    );
  }
}

class Response {
  final int statusCode;
  final dynamic data;

  Response(this.statusCode, this.data);
}

abstract class HttpClient {
  Future<Response> post(String url, Object? data);
}

abstract class Router {
  void redirectToConfirmationPage();

  void goToHomePage();

  void redirectToLoginPage();
}

abstract class AuthStorage {
  void storeToken(AuthToken token);
}

abstract class Form {
  void setFailure(List<String> errors);

  void setError(String fieldName, String message);

  void setSuccess();

  String get(String fieldName);
}
