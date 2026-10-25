import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/purchase_request.dart';
import 'account_avatar.dart';
import 'post_media_thumbnail.dart';

class RequestCard extends StatelessWidget {
  final PurchaseRequest request;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String? avatarBase64;
  final String ownerRole;

  const RequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onDelete,
    this.avatarBase64,
    this.ownerRole = 'مشتري',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkPanel : AppColors.panel;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;
    final fgColor = isDark ? AppColors.darkFg : AppColors.fg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.imageBase64.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostMediaThumbnail(
                      key: ValueKey('request-media-${request.id}'),
                      images: request.imageBase64,
                      width: constraints.maxWidth * 0.34,
                      height: 112,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _header(mutedColor, isDark)),
                  ],
                ),
              )
            else
              _header(mutedColor, isDark),
            const SizedBox(height: 12),
            Text(
              request.title,
              style: TextStyle(
                color: fgColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                AccountAvatar(
                  key: ValueKey('request-avatar-${request.id}'),
                  name: request.buyerName,
                  avatarBase64: avatarBase64,
                  role: ownerRole,
                  size: 30,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${request.buyerName} · ${request.contactPerson}',
                    style: TextStyle(color: mutedColor, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 14, color: mutedColor),
                const SizedBox(width: 4),
                Text(
                  request.quantity,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on_outlined, size: 14, color: mutedColor),
                const SizedBox(width: 4),
                Text(
                  request.location,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 14,
                  color: AppColors.green,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    request.budget,
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (request.deadline != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: AppColors.amber),
                  const SizedBox(width: 6),
                  Text(
                    'آخر موعد: ${request.deadline}',
                    style: const TextStyle(
                      color: AppColors.amber,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(Color mutedColor, bool isDark) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: request.status == 'مفتوح'
                ? AppColors.green.withValues(alpha: 0.12)
                : AppColors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: request.status == 'مفتوح'
                      ? AppColors.green
                      : AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                request.status,
                style: TextStyle(
                  color: request.status == 'مفتوح'
                      ? AppColors.green
                      : AppColors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (request.category != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkPanel2 : AppColors.bg2,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              request.category!,
              style: TextStyle(color: mutedColor, fontSize: 11),
            ),
          ),
        if (onDelete != null)
          IconButton(
            key: ValueKey('delete-request-${request.id}'),
            tooltip: 'حذف طلب الشراء',
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.delete_outline, color: AppColors.red),
          ),
      ],
    );
  }
}
