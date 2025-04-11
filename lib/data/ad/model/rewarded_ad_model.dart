class RewardedAdState {

  const RewardedAdState({
    required this.isLoading,
    required this.isLoaded,
    this.errorMessage,
  });

  factory RewardedAdState.initial() => const RewardedAdState(isLoading: false, isLoaded: false);
  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
}
