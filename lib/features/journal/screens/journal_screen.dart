import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../core/utils/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/journal_service.dart';
import '../../../data/models/journal_entry.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.journalTitle),
      ),
      body: AnimatedBackground(
        child: entriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: StorageService.getJournalEntries(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: Text('Error loading entries'));
                }
                final entries = snap.data!
                    .map((e) => JournalEntry.fromJson(e))
                    .toList()
                  ..sort((a, b) => b.date.compareTo(a.date));
                return entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_note_outlined,
                              size: 80,
                              color: AppColors.mediumGray,
                            )
                                .animate(onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 2000.ms),
                            const SizedBox(height: 16),
                            Text(
                              'No journal entries yet',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.mediumGray,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start writing your thoughts',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.mediumGray,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return _JournalEntryCard(
                            entry: entry,
                            onTap: () {
                              context.push('/journal/${entry.id}');
                            },
                            onDelete: () async {
                              await StorageService.deleteJournalEntry(entry.id);
                            },
                          )
                              .animate(delay: (index * 50).ms)
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: -0.2, end: 0);
                        },
                      );
              },
            );
          },
          data: (list) {
            final entries = list
                .map((e) => JournalEntry.fromJson(e))
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));
            return entries.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note_outlined,
                      size: 80,
                      color: AppColors.mediumGray,
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2000.ms),
                    const SizedBox(height: 16),
                    Text(
                      'No journal entries yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.mediumGray,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start writing your thoughts',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mediumGray,
                          ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _JournalEntryCard(
                    entry: entry,
                    onTap: () {
                      context.push('/journal/${entry.id}');
                    },
                    onDelete: () async {
                      await ref.read(journalServiceProvider).deleteEntry(entry.id);
                    },
                  )
                      .animate(delay: (index * 50).ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.2, end: 0);
                },
              );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/journal/new'),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.journalNewEntry),
      )
          .animate()
          .scale(duration: 300.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 300.ms),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _JournalEntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.formattedDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGray,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (entry.title != null) ...[
                Text(
                  entry.title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                entry.preview,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }
}

