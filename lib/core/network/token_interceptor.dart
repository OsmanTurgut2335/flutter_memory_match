import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor({required this.dio, required this.baseUrl, required this.apiKey, required this.ref});

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

    if (requiresAuth) {
      final user = ref.read(userRepositoryProvider).getUser();

      if (user != null && user.accessToken?.isNotEmpty == true) {
        options.headers['Authorization'] = 'Bearer ${user.accessToken}';
        print('[INTERCEPTOR]  Auth header set: ${options.headers}');
      } else {
        print('[INTERCEPTOR]  User/token not found');
      }
    } else {
      print('[INTERCEPTOR]  Auth not required');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {

    print('${err.response?.statusCode}');
    if (err.response?.statusCode == 401) {
      print('${err.response?.statusCode}');
      final user = ref.read(userRepositoryProvider).getUser();

      if (user == null || user.refreshToken?.isEmpty == true) {
        print('[INTERCEPTOR]  Refresh token or user is missing');
        return handler.next(err);
      }

      try {
        final refreshResponse = await dio.post('$baseUrl/auth/refresh', data: {'refreshToken': user.refreshToken});

        if (refreshResponse.statusCode == 200) {
          final newAccessToken = refreshResponse.data['accessToken'] as String;
          final updatedUser = user.copyWith(accessToken: newAccessToken);

          // save and flush manually for safety
          final box = Hive.box<UserModel>(userBoxName);
          await box.put(userKey, updatedUser);
          await box.flush();
          print('[INTERCEPTOR]  Access token refreshed & saved');

          final retryRequest = err.requestOptions;
          retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';

          final cloned = await dio.fetch(retryRequest);
          return handler.resolve(cloned);
        } else {
          print('[INTERCEPTOR]  Refresh failed: ${refreshResponse.statusCode}');
        }
      } catch (e) {
        print('[INTERCEPTOR] 🔁 Refresh error: $e');
      }
    }

    return handler.next(err);
  }
}
