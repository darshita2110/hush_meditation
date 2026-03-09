import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hush/config/theme/app_colors.dart';
import 'package:hush/config/theme/text_styles.dart';
import 'package:hush/features/journal/controllers/journal_controller.dart';
import 'package:hush/features/ambience/controllers/ambience_controller.dart';

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
  final _journalController = TextEditingController();
  String _selectedMood = 'Calm';
  bool _isSaving = false;

  static const _moods = ['Calm', 'Grounded', 'Energized', 'Sleepy'];

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ambienceAsync = ref.watch(ambienceByIdProvider(widget.ambienceId));

    return ambienceAsync.when(
      data: (ambience) => Scaffold(
        appBar: AppBar(
          title: const Text('Reflection'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ambience title context
              Text(
                ambience.title,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 4),

              // Prompt
              Text(
                'What is gently present with you right now?',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 20),

              // Journal text input
              TextField(
                controller: _journalController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Write your reflection...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 28),

              // Mood selector
              Text('How are you feeling?', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _moods.map((mood) {
                  final isSelected = _selectedMood == mood;
                  return FilterChip(
                    label: Text(mood),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedMood = mood),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.gray900,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _save(ambience.title),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Reflection'),
                ),
              ),

              // Skip without saving
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(
                    'Skip',
                    style:
                        TextStyle(color: AppColors.gray500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Future<void> _save(String ambienceTitle) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(journalProvider.notifier).saveReflection(
            ambienceId: widget.ambienceId,
            ambienceTitle: ambienceTitle,
            journalText: _journalController.text.trim().isEmpty
                ? '(No text written)'
                : _journalController.text.trim(),
            mood: _selectedMood,
          );
      if (mounted) {
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reflection saved ✓'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}