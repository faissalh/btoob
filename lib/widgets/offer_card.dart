import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/offer.dart';
import 'account_avatar.dart';
import 'post_media_thumbnail.dart';

const _gradients = [
  [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  [Color(0xFF059669), Color(0xFF047857)],
  [Color(0xFFF59E0B), Color(0xFFD97706)],
  [Color(0xFFEC4899), Color(0xFFDB2777)],
  [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  [Color(0xFF06B6D4), Color(0xFF0891B2)],
  [Color(0xFFEF4444), Color(0xFFDC2626)],
  [Color(0xFF14B8A6), Color(0xFF0D9488)],
];

class OfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDelete;
  final String? avatarBase64;
  final String ownerRole;

  const OfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onDelete,
    this.avatarBase64,
    this.ownerRole = 'مورد',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkPanel : AppColors.panel;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;
    final fgColor = isDark ? AppColors.darkFg : AppColors.fg;
    final gradient = _gradients[offer.colorIndex % _gradients.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (offer.imageBase64.isEmpty)
              _header(gradient, 56, hasImages: false)
            else
              LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    PostMediaThumbnail(
                      key: ValueKey('offer-media-${offer.id}'),
                      images: offer.imageBase64,
                      width: constraints.maxWidth * 0.42,
                      height: 96,
                    ),
                    Expanded(child: _header(gradient, 96, hasImages: true)),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Text(
                offer.title,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size: 14,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      offer.price,
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (offer.minOrder != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 3, 14, 0),
                child: Text(
                  'الحد الأدنى: ${offer.minOrder}',
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
              child: Row(
                children: [
                  AccountAvatar(
                    key: ValueKey('offer-avatar-${offer.id}'),
                    name: offer.companyName,
                    avatarBase64: avatarBase64,
                    role: ownerRole,
                    size: 28,
                  ),
                  const SizedBox(width: 6),
                  if (offer.isVerified) ...[
                    const Icon(
                      Icons.verified,
                      size: 13,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 3),
                  ],
                  Expanded(
                    child: Text(
                      offer.companyName,
                      style: TextStyle(color: mutedColor, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: AppColors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    offer.rating.toString(),
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(
    List<Color> gradient,
    double height, {
    required bool hasImages,
  }) {
    final controls = <Widget>[
      if (onFavoriteToggle != null)
        IconButton(
          onPressed: onFavoriteToggle,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
          padding: EdgeInsets.zero,
          icon: Icon(
            isFavorite ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
            size: 19,
          ),
        ),
      if (onDelete != null)
        IconButton(
          key: ValueKey('delete-offer-${offer.id}'),
          tooltip: 'حذف العرض',
          onPressed: onDelete,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.delete_outline, color: Colors.white, size: 19),
        ),
    ];

    return Container(
      key: hasImages ? ValueKey('offer-media-info-${offer.id}') : null,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: hasImages
            ? const BorderRadiusDirectional.only(
                topEnd: Radius.circular(AppTheme.radius - 1),
                bottomEnd: Radius.circular(AppTheme.radius - 1),
              )
            : const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radius - 1),
              ),
      ),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: hasImages ? 4 : 12,
        vertical: hasImages ? 6 : 0,
      ),
      child: hasImages
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  offer.type == 'خدمة'
                      ? Icons.build_circle_outlined
                      : Icons.inventory_2_outlined,
                  color: Colors.white70,
                  size: 22,
                ),
                Text(
                  offer.type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: controls,
                ),
              ],
            )
          : Row(
              children: [
                Icon(
                  offer.type == 'خدمة'
                      ? Icons.build_circle_outlined
                      : Icons.inventory_2_outlined,
                  color: Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    offer.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                ...controls,
              ],
            ),
    );
  }
}
