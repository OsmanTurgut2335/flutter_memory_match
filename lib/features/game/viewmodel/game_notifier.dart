import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/game/repository/game_repository.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';
import 'package:mem_game/data/shop_item/repository/shop_repository.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/data/user/repository/user_repository.dart';

class GameNotifier extends StateNotifier<GameState?> {
  GameNotifier(this._repository, this._userRepository, this._shopItemRepository) : super(null) {
    _user = _userRepository.getUser();
  }

  UserModel? _user;

  final UserRepository _userRepository;

  final ShopRepository _shopItemRepository;

  final GameRepository _repository;
  Timer? _timer;
  int? _firstSelectedIndex;
  bool _busy = false;
  bool _isPaused = false;
  bool _hasUsedAd = false;
  bool get hasUsedAd => _hasUsedAd;

  void markAdUsed() {
    _hasUsedAd = true;
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }

  // Callback that the UI can set to show a +10 popup when a score is increased.
  void Function(String scoreText)? onScoreIncrease;

  void Function(GameResult result)? onGameResult;

  GameState? get gameState => state;

  Future<void> clearBestTime() async {
    await _repository.clearBestTime();
  }

  void addExtraLife() {
    if (state != null && state!.health <= 0) {
      state = state!.copyWith(health: 3, isPaused: true);

      _startTimer();
    }
  }

  Future<void> initializeGame(
    bool resumeGame, {
    int bonusHealth = 0,
    bool doubleCoins = false,
    int extraFlipCount = 0,
  }) async {
    if (_user == null) return;

    if (resumeGame) {
      final savedState = await _repository.loadGameState(_user!.username);
      if (savedState != null) {
        state = savedState;
        _isPaused = false;
        _startTimer();
        state = state?.copyWith(isPaused: false);
        return;
      }
    }

    final level = state?.level ?? 1;
    state = GameState(
      cards: generateCardsForLevel(level, preview: true),
      level: level,
      health: 3 + bonusHealth,
      doubleCoins: doubleCoins,
      flipCount: 1 + extraFlipCount,
      showingPreview: true,
    );

    await _repository.saveGameState(state!, _user!.username);

    Future.delayed(const Duration(seconds: 3), () {
      final faceDownCards = state!.cards.map((card) => card.copyWith(isFaceUp: false)).toList();
      state = state!.copyWith(cards: faceDownCards, showingPreview: false);
      this.resumeGame();
    });
  }

  Future<void> advanceLevel() async {
    _timer?.cancel();

    final user = _userRepository.getUser();
    if (user != null) {
      final isDouble = state?.doubleCoins ?? false;
      const baseReward = 100;
      final rewardCoins = isDouble ? baseReward * 2 : baseReward;

      user.coins += rewardCoins;
      await _userRepository.saveUser(user);
    }

    final currentTime = state?.currentTime ?? 0;
    final currentMoves = state?.moves ?? 0;
    final currentScore = state?.score ?? 0;
    final currentLevel = state?.level ?? 1;
    final nextLevel = currentLevel < 7 ? currentLevel + 1 : currentLevel;

    state = GameState(
      cards: generateCardsForLevel(nextLevel, preview: true),
      moves: currentMoves,
      score: currentScore,
      currentTime: currentTime,
      level: nextLevel,
      health: state!.health,
      doubleCoins: state!.doubleCoins,

      showingPreview: true,
    );

    if (user != null) {
      await _repository.saveGameState(state!, user.username);
    }

    Future.delayed(const Duration(seconds: 3), () {
      final faceDownCards = state!.cards.map((card) => card.copyWith(isFaceUp: false)).toList();
      state = state!.copyWith(cards: faceDownCards, showingPreview: false);
      _startTimer();
    });
  }

  void flipCards() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_disposed || state == null) return;

      final updatedCards =
          state!.cards.map((card) {
            return card.isMatched ? card : card.copyWith(isFaceUp: false);
          }).toList();

      state = state!.copyWith(cards: updatedCards, showingPreview: false);
      _startTimer();
    });
  }

  Future<void> flipCardsOnButtonPress() async {
    if (state == null || state!.flipCount <= 0 || _user == null) return;
    _timer?.cancel();
    state = state!.copyWith(flipCount: state!.flipCount - 1, showingPreview: true);
    await _repository.saveGameState(state!, _user!.username);
    flipCards();
  }

  Future<void> restartGame() async {
    _hasUsedAd = false;
    _timer?.cancel();
    if (_user == null) return;
    state = GameState(cards: generateCardsForLevel(1), showingPreview: true);
    await _repository.saveGameState(state!, _user!.username);
    flipCards();
  }

  Future<void> updateBestTimeIfNeeded() async {
    if (state != null) {
      await _repository.updateBestTimeIfNeeded(state!.currentTime);
    }
  }

  List<MemoryCard> generateCardsForLevel(int level, {bool preview = false}) {
    return _repository.generateCardsForLevel(level);
  }

  /// Handles pausing the game
  void pauseGame() {
    _isPaused = true;
    _timer?.cancel();
    state = state?.copyWith(isPaused: true);
  }

  /// Handles resuming the game
  void resumeGame() {
    _isPaused = false;
    _startTimer();
    state = state?.copyWith(isPaused: false);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && state != null) {
        state = state!.copyWith(currentTime: state!.currentTime + 1);
        final user = _userRepository.getUser();
        if (user != null) {
          _repository.saveGameState(state!, user.username);
        }
      }
    });
  }

  Future<void> saveCurrentState() async {
    if (state != null) {
      final user = _userRepository.getUser();
      if (user != null) {
        await _repository.saveGameState(state!, user.username);
      }
    }
  }

  Future<void> onCardTap(int index) async {
    if (_busy || state == null || _isPaused) return;
    if (state!.cards[index].isMatched || state!.cards[index].isFaceUp) return;

    final updatedCards = List<MemoryCard>.from(state!.cards);
    updatedCards[index].isFaceUp = true;
    state = state!.copyWith(cards: updatedCards);

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      state = state!.copyWith(moves: state!.moves + 1);
      final firstIndex = _firstSelectedIndex!;
      _firstSelectedIndex = null;

      if (state!.cards[firstIndex].content == state!.cards[index].content) {
        updatedCards[firstIndex].isMatched = true;
        updatedCards[index].isMatched = true;
        state = state!.copyWith(cards: updatedCards, score: state!.score + 10);
        onScoreIncrease?.call('+10');
      } else {
        _busy = true;
        await Future.delayed(const Duration(seconds: 1));
        updatedCards[firstIndex].isFaceUp = false;
        updatedCards[index].isFaceUp = false;
        state = state!.copyWith(cards: updatedCards, health: state!.health - 1);
        _busy = false;
      }

      if (_user != null) {
        await _repository.saveGameState(state!, _user!.username);
      }

      if (state!.health <= 0) {
        handleLose();
        return;
      }
    }

    if (checkWinCondition()) {
      handleWin();
    }
  }

  void handleWin() {
    _timer?.cancel();
    if (state!.level == 7) {
      updateBestTimeIfNeeded();
    }
    onGameResult?.call(GameResult.win);
  }

  void handleLose() {
    _timer?.cancel();
    onGameResult?.call(GameResult.lose);
  }

  /// **Checks if all cards are matched**
  bool checkWinCondition() {
    if (state!.showingPreview) {
      return false;
    } else {
      return state!.cards.every((card) => card.isMatched);
    }
  }

  /// Exits the game: cancels the timer, deletes the game state, and resets the state.
  Future<void> exitGame() async {
    _timer?.cancel();
    final user = _userRepository.getUser();
    if (user != null) {
      await _repository.deleteGameState(user.username);
    }
    state = null;
  }
}

enum GameResult { win, lose }
