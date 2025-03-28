import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/gamestate/model/game_state_model.dart';
import 'package:mem_game/data/gamestate/repository/game_repository.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({required this.resumeGame, super.key});

  /// If true, we try to resume the saved game state; otherwise, start a new game.
  final bool resumeGame;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GameState _gameState;
  bool _loading = true;
  final GameRepository _gameRepository = GameRepository();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  /// Initializes the game state:
  /// - If resumeGame is true, attempts to load a saved game state.
  /// - Otherwise, creates a new game state.
  Future<void> _initializeGame() async {
    if (widget.resumeGame) {
      final savedState = await _gameRepository.loadGameState();
      if (savedState != null) {
        setState(() {
          _gameState = savedState;
          _loading = false;
        });
        return;
      }
    }
    // If no saved state is found or resumeGame is false, create a new game.
    setState(() {
      _gameState = _createNewGameState();
      _loading = false;
    });
    // Save the new game state.
    await _gameRepository.saveGameState(_gameState);
  }

  /// Creates a new game state with default values.
  GameState _createNewGameState() {
    return GameState(cards: _generateDummyCards());
  }

  /// Generates a list of dummy memory cards.
  List<MemoryCard> _generateDummyCards() {
    return [
      MemoryCard(id: 0, content: 'A'),
      MemoryCard(id: 1, content: 'B'),
      MemoryCard(id: 2, content: 'C'),
      MemoryCard(id: 3, content: 'D'),
      MemoryCard(id: 4, content: 'A'),
      MemoryCard(id: 5, content: 'B'),
      MemoryCard(id: 6, content: 'C'),
      MemoryCard(id: 7, content: 'D'),
    ];
  }

  /// Handles a tap on a card: toggles its face-up state and increments moves.
  void _onCardTap(int index) {
    setState(() {
      final card = _gameState.cards[index];
      card.isFaceUp = !card.isFaceUp;
      _gameState = _gameState.copyWith(moves: _gameState.moves + 1);
    });
    // Save the updated game state.
    _gameRepository.saveGameState(_gameState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Game')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Display game metrics.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Moves: ${_gameState.moves}'),
                        Text('Score: ${_gameState.score}'),
                        Text('Time: ${_gameState.currentTime}'),
                        Text('Health: ${_gameState.health}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Display a grid of memory cards.
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // Adjust as needed.
                            ),
                        itemCount: _gameState.cards.length,
                        itemBuilder: (context, index) {
                          final card = _gameState.cards[index];
                          return GestureDetector(
                            onTap: () => _onCardTap(index),
                            child: Card(
                              color:
                                  card.isFaceUp
                                      ? Colors.white
                                      : Colors.blueAccent,
                              child: Center(
                                child: Text(
                                  card.isFaceUp ? card.content : '',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
