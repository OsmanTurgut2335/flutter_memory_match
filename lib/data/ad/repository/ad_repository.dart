import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdRepository {
  RewardedAd? _rewardedAd;

  /// Loads a rewarded ad.
  Future<void> loadRewardedAd(String adUnitId) async {
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          print('Rewarded ad loaded.');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          print('Failed to load rewarded ad: ${error.message}');
        },
      ),
    );
  }

  /// Shows the rewarded ad.
  void showRewardedAd(void Function(RewardItem reward) onUserEarnedReward) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onUserEarnedReward(reward);
          // Dispose the ad after it's been shown.
          _rewardedAd!.dispose();
          _rewardedAd = null;
        },
      );
    } else {
      print('Rewarded ad is not loaded yet.');
    }
  }
}
