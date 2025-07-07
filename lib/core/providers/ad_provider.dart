import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/ad/model/rewarded_ad_model.dart';
import 'package:mem_game/data/ad/repository/ad_repository.dart';
import 'package:mem_game/features/ad/viewmodel/rewarded_ad_notifier.dart';

/// TODO: replace this test ad unit with your own ad unit
final String adUnitId =
    Platform.isAndroid ? 'ca-app-pub-3940256099942544/5224354917' : 'ca-app-pub-3940256099942544/1712485313';

final rewardedAdNotifierProvider = StateNotifierProvider<RewardedAdNotifier, RewardedAdState>(
  (ref) => RewardedAdNotifier(adUnitId: adUnitId, repository: RewardedAdRepository()),
);
