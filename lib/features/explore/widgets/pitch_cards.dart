import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/tap_scale.dart';
import '../../../core/widgets/turf_image.dart';
import '../../../domain/entities/pitch.dart';

/// A round heart button overlaid on turf photos. Favouriting is a `planned`
/// backend feature, so [onTap] currently surfaces a "coming soon" message.
class HeartButton extends StatelessWidget {
  const HeartButton({
    super.key,
    required this.onTap,
    this.size = 34,
    this.onCard = true,
  });

  final VoidCallback onTap;
  final double size;
  final bool onCard;

  @override
  Widget build(BuildContext context) {
    final heart = Text('♡',
        style: TextStyle(fontSize: size * 0.47, color: AppColors.ink));
    return GestureDetector(
      onTap: onTap,
      child: onCard
          ? Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.92),
                shape: BoxShape.circle,
              ),
              child: heart,
            )
          : heart,
    );
  }
}

/// The wide "Available tonight" card (horizontally scrolled on Explore).
class TonightCard extends StatelessWidget {
  const TonightCard({
    super.key,
    required this.pitch,
    required this.onTap,
    required this.onToggleFav,
  });

  final Pitch pitch;
  final VoidCallback onTap;
  final VoidCallback onToggleFav;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: TurfImage(
                imageUrl: pitch.imageUrl,
                gradient1: Color(pitch.gradient1),
                gradient2: Color(pitch.gradient2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF0A1E16).withValues(alpha: 0.45),
                            ],
                            stops: const [0.55, 1],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        top: 12,
                        right: 12,
                        child: HeartButton(onTap: onToggleFav)),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: TintBadge(
                        text: pitch.verified ? '✓ Verified' : 'Available',
                        background: AppColors.lime,
                        foreground: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(pitch.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.cardTitle),
                      ),
                      Text('★ ${pitch.ratingLabel}',
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Live areas can be long ("2 Winds Paddle Sports - Zanzibar")
                  // and this card has a fixed height — never let it wrap.
                  Text('${pitch.area} · ${pitch.format}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _price(pitch.pricePerHour),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('View Pitch',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact horizontal list row ("Near you").
class PitchListRow extends StatelessWidget {
  const PitchListRow({
    super.key,
    required this.pitch,
    required this.onTap,
    required this.onToggleFav,
  });

  final Pitch pitch;
  final VoidCallback onTap;
  final VoidCallback onToggleFav;

  @override
  Widget build(BuildContext context) {
    final meta = [
      pitch.area,
      '★ ${pitch.ratingLabel}',
      if (pitch.distance != null) pitch.distance!,
    ].join(' · ');

    return TapScale(
      scale: 0.99,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TurfImage(
              imageUrl: pitch.imageUrl,
              gradient1: Color(pitch.gradient1),
              gradient2: Color(pitch.gradient2),
              width: 92,
              height: 88,
              borderRadius: BorderRadius.circular(13),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(pitch.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.cardTitle),
                      ),
                      HeartButton(onTap: onToggleFav, onCard: false, size: 32),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.tiny),
                  const SizedBox(height: 1),
                  Text('${pitch.format} · ${pitch.surface}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.tiny),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      // Shrinks the price rather than overflowing when a
                      // six-figure amount meets the verified badge.
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _price(pitch.pricePerHour, prefix: 'From '),
                        ),
                      ),
                      if (pitch.verified) ...[
                        const SizedBox(width: 6),
                        const TintBadge(text: '✓ Verified'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The tall results card.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.pitch,
    required this.onTap,
    required this.onToggleFav,
  });

  final Pitch pitch;
  final VoidCallback onTap;
  final VoidCallback onToggleFav;

  @override
  Widget build(BuildContext context) {
    final sub = pitch.reviewCount > 0
        ? '${pitch.area} · ${pitch.reviewCount} reviews'
        : pitch.area;

    return TapScale(
      scale: 0.99,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170,
              child: TurfImage(
                imageUrl: pitch.imageUrl,
                gradient1: Color(pitch.gradient1),
                gradient2: Color(pitch.gradient2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Positioned(
                        top: 12,
                        right: 12,
                        child: HeartButton(onTap: onToggleFav, size: 36)),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: TintBadge(
                        text: pitch.verified ? '✓ Verified' : 'Available',
                        background: AppColors.lime,
                        foreground: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                          child: Text(pitch.name, style: AppText.cardTitleLg)),
                      Text('★ ${pitch.ratingLabel}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: AppColors.muted)),
                  const SizedBox(height: 1),
                  Text('${pitch.format} · ${pitch.surface}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small),
                  const SizedBox(height: 8),
                  _price(pitch.pricePerHour, prefix: 'From ', big: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared price label: "From TSh 60,000/hr".
Widget _price(int price, {String prefix = '', bool big = false}) {
  return RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: big ? 15 : 14.5,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      children: [
        TextSpan(text: '$prefix${Formatters.tsh(price)}'),
        TextSpan(
          text: '/hr',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted),
        ),
      ],
    ),
  );
}
