import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mem_game/data/ad/repository/ad_repository.dart';
import 'package:mem_game/data/ad/model/rewarded_ad_model.dart';

class RewardedAdNotifier extends StateNotifier<RewardedAdState> {
  final RewardedAdRepository _repository;
  final String adUnitId;

  RewardedAdNotifier({
    required this.adUnitId,
    required RewardedAdRepository repository,
  })  : _repository = repository,
        super(RewardedAdState.initial());

  /// Loads the rewarded ad and updates the state.
  Future<void> loadAd() async {
    state = const RewardedAdState(isLoading: true, isLoaded: false);
    try {
      await _repository.loadRewardedAd(adUnitId);
      state = const RewardedAdState(isLoading: false, isLoaded: true);
    } catch (e) {
      state = RewardedAdState(isLoading: false, isLoaded: false, errorMessage: e.toString());
    }
  }

  /// Shows the ad and triggers the reward callback.
  void showAd(void Function(RewardItem reward) onUserEarnedReward) {
    if (state.isLoaded) {
      _repository.showRewardedAd((reward) {
        onUserEarnedReward(reward);
        // Reset state after showing ad.
        state = RewardedAdState.initial();
      });
    }
  }
}
