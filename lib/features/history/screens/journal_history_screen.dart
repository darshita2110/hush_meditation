import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:arvyax_flutter_app/config/theme/app_colors.dart';
import 'package:arvyax_flutter_app/config/theme/text_styles.dart';
import 'package:arvyax_flutter_app/features/journal/controllers/journal_controller.dart';

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflections = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal History'),
      ),
      body: reflections.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: AppColors.gray400,
                  ),
                  const SizedBox(height: 16),
                  const Text('No reflections yet.'),
                  const SizedBox(height: 8),
                  const Text('Start a session to begin.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reflections.length,
              itemBuilder: (context, index) {
                final reflection = reflections[index];
                final formattedDate = DateFormat('MMM d, y').format(reflection.createdAt);
                final firstLine = reflection.journalText.split('\n').first;

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(reflection.ambienceTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          firstLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formattedDate, style: AppTextStyles.caption),
                            Chip(
                              label: Text(reflection.mood),
                              labelStyle: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      _showReflectionDetail(context, reflection);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showReflectionDetail(BuildContext context, dynamic reflection) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reflection.ambienceTitle,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM d, y - h:mm a').format(reflection.createdAt),
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            Text(
              reflection.journalText,
              style: AppTextStyles.body1,
            ),
          ],
        ),
      ),
    );
  }
}