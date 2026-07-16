import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ошибка сервера']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет подключения к интернету']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Ошибка авторизации']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Не удалось определить местоположение']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Нет необходимых разрешений']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Не найдено']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Неожиданная ошибка']);
}
