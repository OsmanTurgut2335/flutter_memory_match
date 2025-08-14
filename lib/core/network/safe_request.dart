import 'package:dio/dio.dart';
import 'package:mem_game/core/error/app_exceptions.dart';
import 'package:mem_game/core/error/dio_exception_mapper.dart';

Future<T> safeRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {

if (e.response?.statusCode != null) {
  final statusCode = e.response!.statusCode!;
  if (statusCode == 503) {
    throw const DatabaseDownException(); 
  }
  throw AppExceptionMapper.fromStatusCode(statusCode);
}
 else {
      throw AppExceptionMapper.fromDioException(e);
    }
  } catch (_) {
    throw const UnknownException();
  }
}
