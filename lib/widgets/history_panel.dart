import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calculation.dart';

class HistoryPanel extends StatelessWidget {
  final List<Calculation> history;
  final VoidCallback onClear;

  const HistoryPanel({
    Key? key,
    required this.history,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: history.isNotEmpty ? onClear : null,
                  child: Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? Center(
              child: Text(
                'No calculations yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
                : ListView.builder(
              itemCount: history.length,
              reverse: true,
              itemBuilder: (context, index) {
                final calc = history[index];
                return ListTile(
                  title: Text(calc.displayText),
                  trailing: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: calc.result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Result copied')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}