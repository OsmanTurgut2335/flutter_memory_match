import 'package:dio/dio.dart';
import 'package:mem_game/core/error/app_exceptions.dart';

class AppExceptionMapper {
  static AppException fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return const BadRequestException();
      case 401:
        return const UnauthorizedException();
      case 403:
        return const ForbiddenException();
      case 404:
        return const NotFoundException();
      case 409:
        return const ConflictException();
      case 500:
        return const ServerException();
      default:
        return const UnknownException();
    }
  }

  static AppException fromDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException();
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return const NetworkException();
    }

    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      return fromStatusCode(statusCode);
    }

    return const UnknownException();
  }
}
