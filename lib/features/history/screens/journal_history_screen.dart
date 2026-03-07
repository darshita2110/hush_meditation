import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:arvyax_flutter_app/config/theme/app_colors.dart';
import 'package:arvyax_flutter_app/config/theme/text_styles.dart';
import 'package:arvyax_flutter_app/features/journal/controllers/journal_controller.dart';
import 'package:arvyax_flutter_app/data/models/reflection_model.dart';

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflections = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal History')),
      body: reflections.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined,
                      size: 64, color: AppColors.gray400),
                  const SizedBox(height: 16),
                  Text('No reflections yet.',
                      style: AppTextStyles.body1
                          .copyWith(color: AppColors.gray600)),
                  const SizedBox(height: 8),
                  Text('Start a session to begin.',
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.gray400)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reflections.length,
              itemBuilder: (context, index) {
                final r = reflections[index];
                final formattedDate =
                    DateFormat('MMM d, y').format(r.createdAt);
                final preview = r.journalPreview;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(r.ambienceTitle,
                        style: AppTextStyles.h5),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.gray600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formattedDate,
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.gray500)),
                            _MoodChip(mood: r.mood),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => _showDetail(context, r),
                  ),
                );
              },
            ),
    );
  }

  void _showDetail(BuildContext context, ReflectionModel r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(r.ambienceTitle, style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, y – h:mm a').format(r.createdAt),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.gray500),
              ),
              const SizedBox(height: 8),
              _MoodChip(mood: r.mood),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Text(r.journalText, style: AppTextStyles.body1),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String mood;
  const _MoodChip({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        mood,
        style:
            AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
      ),
    );
  }
}