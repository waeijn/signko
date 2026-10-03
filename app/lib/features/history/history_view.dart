import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/history_provider.dart';
import '../settings/settings_provider.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveHistory = ref.watch(settingsProvider).saveHistory;
    final historyState = ref.watch(historyProvider);
    final historyItems = historyState.items;
    final isLoading = historyState.isLoading;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Clear History',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text(
                      'Are you sure you want to delete all translation history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(historyProvider.notifier).clearHistory();
                      },
                      child: const Text('Clear',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading && historyItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!saveHistory && historyItems.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    color: Colors.amber.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.history_toggle_off,
                            color: Colors.amber.shade900, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'History saving is disabled. New translations will not appear here.',
                            style: TextStyle(
                                color: Colors.amber.shade900, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: historyItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    saveHistory
                                        ? Icons.history
                                        : Icons.history_toggle_off,
                                    size: 64,
                                    color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                    saveHistory
                                        ? 'No history yet'
                                        : 'History is disabled',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(
                                  saveHistory
                                      ? 'Translations will appear here once you start using the app.'
                                      : 'Enable "Save translation history" in Settings to keep track of your translations.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24.0),
                          itemCount: historyItems.length,
                          itemBuilder: (context, index) {
                            final item = historyItems[index];

                            // Grouping by Date header
                            bool showHeader = false;
                            String headerText = '';

                            if (index == 0) {
                              showHeader = true;
                            } else {
                              final prevItem = historyItems[index - 1];
                              if (item.createdAt.day !=
                                      prevItem.createdAt.day ||
                                  item.createdAt.month !=
                                      prevItem.createdAt.month ||
                                  item.createdAt.year !=
                                      prevItem.createdAt.year) {
                                showHeader = true;
                              }
                            }

                            if (showHeader) {
                              final now = DateTime.now();
                              if (item.createdAt.day == now.day &&
                                  item.createdAt.month == now.month &&
                                  item.createdAt.year == now.year) {
                                headerText = 'Today';
                              } else {
                                headerText = DateFormat('MMMM d, yyyy')
                                    .format(item.createdAt);
                              }
                            }

                            final timeFormatted =
                                DateFormat('h:mm a').format(item.createdAt);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader) ...[
                                  if (index != 0) const SizedBox(height: 32),
                                  Text(
                                    headerText,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildHistoryItem(
                                    context,
                                    item.sourceText,
                                    item.translatedText,
                                    item.mode,
                                    timeFormatted,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
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
                Text(translated,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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
