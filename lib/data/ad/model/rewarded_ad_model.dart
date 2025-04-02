class RewardedAdState {
  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;

  const RewardedAdState({
    required this.isLoading,
    required this.isLoaded,
    this.errorMessage,
  });

  factory RewardedAdState.initial() => const RewardedAdState(isLoading: false, isLoaded: false);
}
