import 'package:flutter/material.dart';
import 'package:hush/config/theme/app_colors.dart';
import 'package:hush/config/theme/text_styles.dart';
import 'package:hush/data/models/ambience_model.dart';

class AmbienceCard extends StatelessWidget {
  final AmbienceModel ambience;
  final VoidCallback onTap;

  const AmbienceCard({
    super.key,
    required this.ambience,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Card image slot is roughly half the card height inside a 2-column grid.
    // Decode at 2× the logical pixel width (≈200px) to cover hi-DPI screens
    // without decoding the full original resolution every rebuild.
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheW = (200 * devicePixelRatio).round();

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
            // ── Image area ─────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient shown instantly while image decodes,
                  // and as a permanent fallback if the asset is missing.
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.breathingGradient,
                    ),
                  ),
                  Image.asset(
                    ambience.imagePath,
                    fit: BoxFit.cover,
                    // cacheWidth tells Flutter's image cache to store the
                    // decoded bitmap at this width instead of full resolution.
                    // Re-scrolling the grid reuses the cached bitmap instantly.
                    cacheWidth: cacheW,
                    // gaplessPlayback prevents the image flickering back to
                    // the gradient placeholder on every widget rebuild.
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // ── Text content ───────────────────────────────────────────
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