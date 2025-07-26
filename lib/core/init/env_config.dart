import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {

  EnvConfig()
      : apiKey = dotenv.env['API_KEY'] ?? '',
        baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8080';
  final String apiKey;
  final String baseUrl;
}
