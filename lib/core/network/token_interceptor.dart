import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor({required this.dio, required this.baseUrl, required this.apiKey});
  final Dio dio;
  final String baseUrl;
  final String apiKey;

@override
Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

  options.headers['x-api-key'] = apiKey;


  final requiresAuth = options.extra['auth'] != false;

  if (requiresAuth) {
    final box = Hive.box<UserModel>('userBox');
    final user = box.get('user');

    if (user != null && user.accessToken?.isNotEmpty == true) {
      options.headers['Authorization'] = 'Bearer ${user.accessToken}';
    }
  }

  return handler.next(options);
}


  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final box = Hive.box<UserModel>('userBox');
      final user = box.get('user');

      if (user == null || user.refreshToken?.isEmpty == true) {
        return handler.next(err);
      }

      try {
        final refreshResponse = await dio.post('$baseUrl/auth/refresh', data: {'refreshToken': user.refreshToken});

        if (refreshResponse.statusCode == 200) {
          final newAccessToken = refreshResponse.data['accessToken'] as String;

         
          final updatedUser = user.copyWith(accessToken: newAccessToken);
          await box.put('user', updatedUser);

        
          final retryRequest = err.requestOptions;
          retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';

          final cloned = await dio.fetch(retryRequest);
          return handler.resolve(cloned);
        }
      } catch (_) {
   
      }
    }

    return handler.next(err);
  }
}
