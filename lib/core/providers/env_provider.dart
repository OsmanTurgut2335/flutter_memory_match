

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/init/env_config.dart';

final envConfigProvider = Provider<EnvConfig>((ref) => EnvConfig());
