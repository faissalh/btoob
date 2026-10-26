import 'package:flutter/material.dart';

import '../l10n/post_card_localizations.dart';
import '../theme/app_theme.dart';
import 'account_avatar.dart';
import 'post_media_thumbnail.dart';

class PostCard extends StatelessWidget {
  final String id;
  final String title;
  final String publisherName;
  final String ownerRole;
  final String? avatarBase64;
  final Key? avatarKey;
  final double? rating;
  final bool isVerified;
  final List<String> images;
  final IconData? typeIcon;
  final String? typeLabel;
  final Color typeColor;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDelete;
  final Key? deleteKey;
  final String? deleteTooltip;
  final String primaryText;
  final IconData primaryIcon;
  final Color primaryColor;
  final String? secondaryText;
  final String? description;
  final List<Widget> additionalDetails;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.id,
    required this.title,
    required this.publisherName,
    required this.ownerRole,
    this.avatarBase64,
    this.avatarKey,
    this.rating,
    this.isVerified = false,
    this.images = const [],
    this.typeIcon,
    this.typeLabel,
    this.typeColor = AppColors.accent,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onDelete,
    this.deleteKey,
    this.deleteTooltip,
    required this.primaryText,
    required this.primaryIcon,
    this.primaryColor = AppColors.green,
    this.secondaryText,
    this.description,
    this.additionalDetails = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkPanel : AppColors.panel;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;
    final fgColor = isDark ? AppColors.darkFg : AppColors.fg;
    final localizations = postCardLocalizations(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AccountAvatar(
                  key: avatarKey ?? ValueKey('post-avatar-$id'),
                  name: publisherName,
                  avatarBase64: avatarBase64,
                  role: ownerRole,
                  size: 34,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          publisherName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: fgColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 4),
                        Tooltip(
                          message: localizations.verifiedPublisher,
                          child: const Icon(
                            Icons.verified,
                            size: 15,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: AppColors.amber,
                ),
                const SizedBox(width: 2),
                Text(
                  rating?.toString() ?? localizations.ratingUnavailable,
                  style: TextStyle(
                    color: fgColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (images.isEmpty && onDelete != null) ...[
                  const SizedBox(width: 4),
                  _RoundAction(
                    key: deleteKey,
                    tooltip: deleteTooltip ?? '',
                    icon: Icons.delete_outline,
                    color: AppColors.red,
                    onPressed: onDelete,
                  ),
                ],
                if (images.isEmpty && onFavoriteToggle != null) ...[
                  const SizedBox(width: 4),
                  _RoundAction(
                    tooltip: isFavorite
                        ? localizations.removeSavedPost
                        : localizations.savePost,
                    icon: isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: AppColors.accent,
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ],
            ),
            if (images.isNotEmpty) ...[
              const SizedBox(height: 10),
              PostMediaThumbnail(
                key: ValueKey('post-media-$id'),
                images: images,
                typeIcon: typeIcon,
                typeLabel: typeLabel,
                typeColor: typeColor,
                isFavorite: isFavorite,
                onFavoriteToggle: onFavoriteToggle,
                deleteTooltip: deleteTooltip,
                onDelete: onDelete,
                deleteKey: deleteKey,
              ),
            ] else if (typeIcon != null && typeLabel != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Tooltip(
                  message: typeLabel!,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TypeIcon(icon: typeIcon!, color: typeColor),
                      const SizedBox(width: 6),
                      Text(
                        typeLabel!,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fgColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(primaryIcon, size: 16, color: primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    primaryText,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (description != null && description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: mutedColor, fontSize: 12, height: 1.4),
              ),
            ],
            if (secondaryText != null && secondaryText!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                secondaryText!,
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
            ],
            if (additionalDetails.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 10, runSpacing: 6, children: additionalDetails),
            ],
          ],
        ),
      ),
    );
  }
}

class PostDetailLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const PostDetailLabel({
    super.key,
    required this.icon,
    required this.text,
    this.color = AppColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

class PostStatusBadge extends StatelessWidget {
  final String label;
  final bool isOpen;

  const PostStatusBadge({super.key, required this.label, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.green : AppColors.red;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _RoundAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 32,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _TypeIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: 17, color: Colors.white),
    );
  }
}
