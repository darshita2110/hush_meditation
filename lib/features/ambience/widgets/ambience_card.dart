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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / gradient
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.breathingGradient,
                    ),
                  ),
                  Image.asset(
                    ambience.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            // Text content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      ambience.title,
                      style: AppTextStyles.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      ambience.tag,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                    ),
                    Text(
                      ambience.durationDisplay,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.gray500),
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