import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor({
    required this.dio,
    required this.baseUrl,
    required this.apiKey,
    required this.ref,
  });

  final Dio dio;
  final String baseUrl;
  final String apiKey;
  final Ref ref;

  static const String userBoxName = 'userBox';
  static const String userKey = 'currentUser';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['x-api-key'] = apiKey;

    final requiresAuth = !(options.extra.containsKey('auth') && options.extra['auth'] == false);
    if (!requiresAuth) return handler.next(options);

    UserModel? user = ref.read(userRepositoryProvider).getUser();

    if (user != null && user.accessToken?.isNotEmpty == true) {
      final isExpired = _isJwtExpired(user.accessToken!);

      if (isExpired) {
        print('[INTERCEPTOR] Access token expired before request. Attempting to refresh...');
        final success = await _tryRefreshToken(user);
        if (!success) {
          print('[INTERCEPTOR] Refresh failed. Proceeding without token.');
          return handler.next(options);
        }
        user = ref.read(userRepositoryProvider).getUser();
      }

      if (user?.accessToken?.isNotEmpty == true) {
        options.headers['Authorization'] = 'Bearer ${user!.accessToken}';
        print('[INTERCEPTOR] Auth header set: ${options.headers}');
      }
    } else {
      print('[INTERCEPTOR] No access token found.');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    print('[INTERCEPTOR] Error status code: $statusCode');

    if (statusCode == 401 && err.requestOptions.extra['refreshed'] != true) {
      final user = ref.read(userRepositoryProvider).getUser();

      if (user == null || user.refreshToken?.isEmpty == true) {
        print('[INTERCEPTOR] Refresh token or user is missing');
        return handler.next(err);
      }

      final refreshed = await _tryRefreshToken(user);
      if (refreshed) {
        final newUser = ref.read(userRepositoryProvider).getUser();
        if (newUser?.accessToken != null) {
          final retryRequest = err.requestOptions.copyWith(
            headers: {
              'x-api-key': apiKey,
              'Authorization': 'Bearer ${newUser!.accessToken}',
            },
            extra: {
              ...err.requestOptions.extra,
              'refreshed': true,
            },
          );

          final response = await dio.fetch(retryRequest);
          return handler.resolve(response);
        }
      }
    }

    return handler.next(err);
  }

  bool _isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final claims = json.decode(payload) as Map<String, dynamic>;

      final exp = claims['exp'];
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      print('[JWT] Expiry check failed: $e');
      return true;
    }
  }
  
Future<bool> _tryRefreshToken(UserModel user) async {
  try {
    final response = await dio.post(
      '$baseUrl/auth/refresh',
      data: {'refreshToken': user.refreshToken},
      options: Options(
        extra: {'auth': false},
        validateStatus: (_) => true,
      ),
    );

    if (response.statusCode == 200) {
      final newAccessToken = response.data['accessToken'] as String;
      final updatedUser = user.copyWith(accessToken: newAccessToken);

      final box = Hive.box<UserModel>(userBoxName);
      await box.put(userKey, updatedUser);
      await box.flush();

      print('[INTERCEPTOR] Access token refreshed & saved');
      return true;
    } else {
      print('[INTERCEPTOR] Refresh failed with status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('[INTERCEPTOR] Refresh error: $e');
    return false;
  }
}


}
