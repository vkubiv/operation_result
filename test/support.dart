import 'package:operation_result/operation_result.dart';

class Failure1 {
  final String message;

  Failure1(this.message);
}

class Failure2 {
  final String message;

  Failure2(this.message);
}

class Failure3 {
  final String message;

  Failure3(this.message);
}

class Failure4 {
  final String message;

  Failure4(this.message);
}

class Failure5 {
  final String message;

  Failure5(this.message);
}

class Failure6 {
  final String message;

  Failure6(this.message);
}

class UnspecifiedFailure {
  final String message;

  UnspecifiedFailure(this.message);
}

Result<int, Errors1<UnspecifiedFailure>> resultObjectWithIncorrectState() {
  return Result.error([], Errors1());
}
