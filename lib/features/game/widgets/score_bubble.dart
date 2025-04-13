import 'package:flutter/material.dart';

class ScoreBubble extends StatefulWidget {
  const ScoreBubble({Key? key, required this.label, required this.value}) : super(key: key);

  final String label;
  final String value;

  @override
  ScoreBubbleState createState() => ScoreBubbleState();
}

class ScoreBubbleState extends State<ScoreBubble> {
  bool _showIncrement = false;
  String _incrementText = '+10';

  void showIncrement(String text) {
    setState(() {
      _incrementText = text;
      _showIncrement = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showIncrement = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Your normal score bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 4)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label, style: const TextStyle(fontSize: 12, color: Colors.indigo)),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ],
          ),
        ),
        // The popup overlay, e.g. "+10"
        if (_showIncrement)
          Positioned(
            top: 30,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showIncrement ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  _incrementText,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
