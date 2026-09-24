import 'package:flutter/material.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text('Today',
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildHistoryItem(
              context, 'I love you', 'Mahal kita', 'Sign to Text', '10:42 AM'),
          const SizedBox(height: 12),
          _buildHistoryItem(
              context, 'Thank you', 'Salamat', 'Text to Sign', '09:15 AM'),
          const SizedBox(height: 32),
          const Text('Yesterday',
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildHistoryItem(context, 'How are you?', 'Kamusta ka?',
              'Sign to Text', '04:30 PM'),
          const SizedBox(height: 12),
          _buildHistoryItem(context, 'Good morning', 'Magandang umaga',
              'Text to Sign', '08:00 AM'),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String original,
      String translated, String mode, String time) {
    final isSignToText = mode == 'Sign to Text';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSignToText ? Colors.blue.shade50 : Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSignToText ? Icons.back_hand : Icons.chat_bubble_outline,
              color: isSignToText ? Colors.blue : Colors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(original,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(translated, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(time,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }
}
