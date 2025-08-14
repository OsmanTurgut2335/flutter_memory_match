import 'package:easy_localization/easy_localization.dart';

abstract class AppException implements Exception {

  const AppException(this.localizationKey, {this.statusCode});
  final String localizationKey;
  final int? statusCode;

  @override
  String toString() => '$runtimeType: $localizationKey';
}

class BadRequestException extends AppException {
  const BadRequestException() : super('errors.bad_request', statusCode: 400);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('errors.unauthorized', statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException() : super('errors.forbidden', statusCode: 403);
}

class NotFoundException extends AppException {
  const NotFoundException() : super('errors.not_found', statusCode: 404);
}

class ConflictException extends AppException {
  const ConflictException() : super('errors.conflict', statusCode: 409);
}

class ServerException extends AppException {
  const ServerException() : super('errors.server', statusCode: 500);
}

class NetworkException extends AppException {
  const NetworkException() : super('errors.network');
}

class UnknownException extends AppException {
  const UnknownException() : super('errors.unknown');
}

class IncompleteResponseException extends AppException {
  const IncompleteResponseException() : super('errors.incomplete_response');
}

class TimeoutException extends AppException {
  const TimeoutException() : super('errors.timeout');
}
class DatabaseDownException extends AppException {
  const DatabaseDownException() : super('errors.db_down', statusCode: 503);
}


extension AppExceptionX on AppException {
  String get localizedMessage => localizationKey.tr();
}

