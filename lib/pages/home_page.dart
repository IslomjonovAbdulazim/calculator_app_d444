import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'game_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Difficulty selectedDifficulty = Difficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chess Game'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.game_controller_solid,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 40),

              _buildGameModeButton(
                title: 'Two Players',
                subtitle: 'Play with a friend',
                icon: Icons.people,
                onTap: () => _startGame(GameMode.twoPlayer),
              ),

              SizedBox(height: 20),

              _buildGameModeButton(
                title: 'vs Computer',
                subtitle: 'Play against AI',
                icon: Icons.computer,
                onTap: () => _showDifficultyDialog(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 48),
              SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Difficulty.values.map((difficulty) {
            return RadioListTile<Difficulty>(
              title: Text(_getDifficultyName(difficulty)),
              value: difficulty,
              groupValue: selectedDifficulty,
              onChanged: (value) {
                setState(() {
                  selectedDifficulty = value!;
                });
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame(GameMode.vsAi);
            },
            child: Text('Start Game'),
          ),
        ],
      ),
    );
  }

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  void _startGame(GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          gameMode: mode,
          difficulty: selectedDifficulty,
        ),
      ),
    );
  }
}