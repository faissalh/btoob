import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/company.dart';
import 'account_avatar.dart';

class CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback? onTap;
  final String? avatarBase64;

  const CompanyCard({
    super.key,
    required this.company,
    this.onTap,
    this.avatarBase64,
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
            Row(
              children: [
                AccountAvatar(
                  key: ValueKey('company-avatar-${company.id}'),
                  name: company.name,
                  avatarBase64: avatarBase64,
                  role: company.type,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              company.name,
                              style: TextStyle(
                                color: fgColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (company.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.accent,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: company.type == 'مصنع'
                                  ? AppColors.green.withValues(alpha: 0.1)
                                  : AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              company.type,
                              style: TextStyle(
                                color: company.type == 'مصنع'
                                    ? AppColors.green
                                    : AppColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: mutedColor,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              company.location,
                              style: TextStyle(color: mutedColor, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              company.description,
              style: TextStyle(color: mutedColor, fontSize: 13, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  '${company.rating}',
                  style: TextStyle(
                    color: fgColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' (${company.reviewCount})',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                const Spacer(),
                Icon(Icons.local_offer_outlined, size: 14, color: mutedColor),
                const SizedBox(width: 4),
                Text(
                  '${company.offersCount} عرض',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
