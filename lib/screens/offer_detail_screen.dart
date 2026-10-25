import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/offer.dart';
import '../data/mock_data.dart';
import 'company_detail_screen.dart';
import '../widgets/account_avatar.dart';
import '../widgets/marketplace_media_image.dart';

class OfferDetailScreen extends StatelessWidget {
  final Offer offer;
  final ValueChanged<String>? onContact;
  final String? avatarBase64;
  final String ownerRole;

  const OfferDetailScreen({
    super.key,
    required this.offer,
    this.onContact,
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.accent, AppColors.accent2],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        offer.type == 'خدمة'
                            ? Icons.build_circle_outlined
                            : Icons.inventory_2_outlined,
                        size: 52,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSm,
                          ),
                        ),
                        child: Text(
                          offer.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ رابط العرض')),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ العرض في المفضلة')),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (offer.imageBase64.isNotEmpty) ...[
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: offer.imageBase64.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) => ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSm,
                          ),
                          child: MarketplaceMediaImage(
                            source: offer.imageBase64[index],
                            width: 190,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkPanel2 : AppColors.bg2,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Text(
                      offer.category,
                      style: TextStyle(color: mutedColor, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Price card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          color: AppColors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'السعر',
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offer.price,
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (offer.minOrder != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'الحد الأدنى',
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offer.minOrder!,
                                style: TextStyle(
                                  color: fgColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (offer.description != null) ...[
                    Text(
                      'وصف العرض',
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offer.description!,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (offer.features.isNotEmpty) ...[
                    Text(
                      'المميزات',
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...offer.features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                f,
                                style: TextStyle(
                                  color: fgColor,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    'الدول المستهدفة',
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: offer.countries
                        .map(
                          (c) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkPanel2
                                  : AppColors.bg2,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.public, size: 14, color: mutedColor),
                                const SizedBox(width: 6),
                                Text(
                                  c,
                                  style: TextStyle(
                                    color: fgColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'المورد',
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      final company = MockData.getCompanyByName(
                        offer.companyName,
                      );
                      if (company != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompanyDetailScreen(
                              company: company,
                              avatarBase64: avatarBase64,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          AccountAvatar(
                            key: const ValueKey('offer-detail-avatar'),
                            name: offer.companyName,
                            avatarBase64: avatarBase64,
                            role: ownerRole,
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
                                        offer.companyName,
                                        style: TextStyle(
                                          color: fgColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (offer.isVerified) ...[
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
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 15,
                                      color: AppColors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${offer.rating}',
                                      style: TextStyle(
                                        color: fgColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: mutedColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onContact?.call(offer.companyName),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        'تواصل مع المورد',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => onContact?.call(offer.companyName),
                      icon: const Icon(Icons.request_quote_outlined),
                      label: const Text(
                        'طلب عرض سعر',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
