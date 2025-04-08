import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/game/repository/game_repository.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';

class GameNotifier extends StateNotifier<GameState?> {
  // Track pause state

  GameNotifier(this._repository) : super(null);
  final GameRepository _repository;
  Timer? _timer;
  int? _firstSelectedIndex;
  bool _busy = false;
  bool _isPaused = false;

  GameState? get gameState => state;

  Future<void> clearBestTime() async {
    await _repository.clearBestTime();
  }

  void addExtraLife() {
    if (state != null && state!.health <= 0) {
      state = state!.copyWith(health: 1, isPaused: true);
      _startTimer();
    }
  }

 Future<void> initializeGame(bool resumeGame) async {
  if (resumeGame) {
    final savedState = await _repository.loadGameState();
    if (savedState != null) {
      state = savedState;
      _startTimer();
      return;
    }
  }

  final level = state?.level ?? 1;

  state = GameState(
    cards: _generateCardsForLevel(level),
    level: level,
    showingPreview: true,
  );
  await _repository.saveGameState(state!);

  // Schedule preview end and timer start
  Future.delayed(const Duration(seconds: 3), () {
    final faceDownCards = state!.cards
        .map((card) => card.copyWith(isFaceUp: false))
        .toList();
    state = state!.copyWith(cards: faceDownCards, showingPreview: false);
    _startTimer();
  });
}


  GameState _createNewGameState() {
    final level = state?.level ?? 1;
    return GameState(cards: _generateCardsForLevel(level));
  }

  /*
  Future<void> restartGame() async {
    _timer?.cancel();
    state = _createNewGameState();
    await _repository.saveGameState(state!);
    _startTimer();
  }*/

  Future<void> restartGame() async {
    _timer?.cancel();

    final level = state?.level ?? 1;

    // 1) Create a new game state with preview ON
    state = GameState(cards: _generateCardsForLevel(level), level: level, showingPreview: true);
    await _repository.saveGameState(state!);

    // 2) Schedule (but do not await) the preview turning off
    Future.delayed(const Duration(seconds: 3), () {
      // Flip all cards face-down and clear preview flag
      final faceDownCards = state!.cards.map((card) => card.copyWith(isFaceUp: false)).toList();
      state = state!.copyWith(cards: faceDownCards, showingPreview: false);

      // 3) Start the timer only after preview ends
      _startTimer();
    });
  }

  Future<void> updateBestTimeIfNeeded() async {
    if (state != null) {
      await _repository.updateBestTimeIfNeeded(state!.currentTime);
    }
  }

  /// Generates a shuffled list of MemoryCard objects for the given level.
  /// Level 1: uses assets/card_images/level1 → 6 images → 12 cards
  /// Level 2: uses assets/card_images/level2 → 8 images → 16 cards
  /// Level 3: uses assets/card_images/level3 → 12 images → 24 cards
  List<MemoryCard> _generateCardsForLevel(int level, {bool preview = false}) {
    final levelImages = switch (level) {
      1 => List<String>.generate(6, (i) => 'assets/card_images/level1/card$i.png'),
      2 => List<String>.generate(8, (i) => 'assets/card_images/level2/card$i.png'),
      3 => List<String>.generate(12, (i) => 'assets/card_images/level3/card$i.png'),
      _ => List<String>.generate(6, (i) => 'assets/card_images/level1/card$i.png'),
    };

    final allPaths = [for (var path in levelImages) path, for (var path in levelImages) path]..shuffle();

    return List<MemoryCard>.generate(
      allPaths.length,
      (index) => MemoryCard(
        id: index,
        content: allPaths[index],
        isFaceUp: preview, // 👈 Show cards face up initially if preview is true
      ),
    );
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
        _repository.saveGameState(state!);
      }
    });
  }

  Future<void> saveCurrentState() async {
    if (state != null) {
      await _repository.saveGameState(state!);
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
      } else {
        _busy = true;
        await Future.delayed(const Duration(seconds: 1));
        updatedCards[firstIndex].isFaceUp = false;
        updatedCards[index].isFaceUp = false;
        state = state!.copyWith(cards: updatedCards, health: state!.health - 1);
        _busy = false;
      }

      await _repository.saveGameState(state!);

      if (state!.health <= 0) {
        handleLose();

        return;
      }
    }

    //  Check for win condition
    if (checkWinCondition()) {
      handleWin();
    }
  }

  void handleWin() {
    _timer?.cancel(); // Stop the timer when the game is won

    // Call updateBestTimeIfNeeded to update the user's best time
    updateBestTimeIfNeeded();

    // Notify UI by copying the state (if needed)
    state = state!.copyWith();
  }

  void handleLose() {
    _timer?.cancel(); // Stop the timer when the game is won

    // Notify UI by copying the state (if needed)
    state = state!.copyWith();
  }

  /// **Checks if all cards are matched**
  bool checkWinCondition() {
    return state!.cards.every((card) => card.isMatched);
  }

  /// Exits the game: cancels the timer, deletes the game state, and resets the state.
  Future<void> exitGame() async {
    _timer?.cancel();
    await _repository.deleteGameState();
    state = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
