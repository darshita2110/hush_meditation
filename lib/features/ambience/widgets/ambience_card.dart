import 'package:flutter/material.dart';
import 'package:arvyax_flutter_app/config/theme/app_colors.dart';
import 'package:arvyax_flutter_app/config/theme/text_styles.dart';
import 'package:arvyax_flutter_app/data/models/ambience_model.dart';

class AmbienceCard extends StatelessWidget {
  final AmbienceModel ambience;
  final VoidCallback onTap;

  const AmbienceCard({
    Key? key,
    required this.ambience,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: AppColors.breathingGradient,
              ),
              child: Image.asset(
                ambience.imagePath,
                fit: BoxFit.cover,
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ambience.title,
                      style: AppTextStyles.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ambience.tag,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ambience.durationMinutes}-${ambience.durationMinutes + 1} min',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}