import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arvyax_flutter_app/config/theme/app_colors.dart';
import 'package:arvyax_flutter_app/config/theme/text_styles.dart';
import 'package:arvyax_flutter_app/features/journal/controllers/journal_controller.dart';
import 'package:arvyax_flutter_app/features/ambience/controllers/ambience_controller.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  final String ambienceId;

  const ReflectionScreen({
    Key? key,
    required this.ambienceId,
  }) : super(key: key);

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _journalController = TextEditingController();_app
  String _selectedMood = 'Calm';

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambienceAsync = ref.watch(ambienceByIdProvider(widget.ambienceId));

    return ambienceAsync.when(
      data: (ambience) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reflection'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is gently present with you right now?',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 20),
                // Journal Text Input
                TextField(
                  controller: _journalController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Write your reflection...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                // Mood Selector
                Text(
                  'How are you feeling?',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Calm', 'Grounded', 'Energized', 'Sleepy'].map((mood) {
                    final isSelected = _selectedMood == mood;
                    return FilterChip(
                      label: Text(mood),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedMood = mood);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.gray900,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(journalProvider.notifier).saveReflection(
                            ambienceId: widget.ambienceId,
                            ambienceTitle: ambience.title,
                            journalText: _journalController.text,
                            mood: _selectedMood,
                          );
                      if (mounted) {
                        context.go('/');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reflection saved!')),
                        );
                      }
                    },
                    child: const Text('Save Reflection'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}