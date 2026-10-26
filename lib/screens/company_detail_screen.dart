import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/company.dart';
import '../data/mock_data.dart';
import '../widgets/offer_card.dart';
import 'offer_detail_screen.dart';
import '../widgets/account_avatar.dart';

class CompanyDetailScreen extends StatelessWidget {
  final Company company;
  final ValueChanged<String>? onContact;
  final String? avatarBase64;
  final Set<String> favorites;
  final ValueChanged<String>? onToggleFavorite;

  const CompanyDetailScreen({
    super.key,
    required this.company,
    this.onContact,
    this.avatarBase64,
    this.favorites = const {},
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkPanel : AppColors.panel;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;
    final fgColor = isDark ? AppColors.darkFg : AppColors.fg;
    final companyOffers = MockData.getCompanyOffers(company.name);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: company.type == 'مصنع'
                        ? [const Color(0xFF059669), const Color(0xFF047857)]
                        : [AppColors.accent, AppColors.accent2],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      AccountAvatar(
                        key: const ValueKey('company-detail-avatar'),
                        name: company.name,
                        avatarBase64: avatarBase64,
                        role: company.type,
                        size: 72,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            company.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (company.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              size: 20,
                              color: Colors.white,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSm,
                          ),
                        ),
                        child: Text(
                          company.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _row(
                          Icons.location_on_outlined,
                          'الموقع',
                          company.location,
                          fgColor,
                          mutedColor,
                        ),
                        const SizedBox(height: 12),
                        _row(
                          Icons.star_rounded,
                          'التقييم',
                          '${company.rating} (${company.reviewCount} تقييم)',
                          fgColor,
                          mutedColor,
                        ),
                        const SizedBox(height: 12),
                        _row(
                          Icons.local_offer_outlined,
                          'العروض',
                          '${company.offersCount} عرض',
                          fgColor,
                          mutedColor,
                        ),
                        if (company.yearEstablished != null) ...[
                          const SizedBox(height: 12),
                          _row(
                            Icons.calendar_today_outlined,
                            'سنة التأسيس',
                            '${company.yearEstablished}',
                            fgColor,
                            mutedColor,
                          ),
                        ],
                        if (company.phone != null) ...[
                          const SizedBox(height: 12),
                          _row(
                            Icons.phone_outlined,
                            'الهاتف',
                            company.phone!,
                            fgColor,
                            mutedColor,
                          ),
                        ],
                        if (company.email != null) ...[
                          const SizedBox(height: 12),
                          _row(
                            Icons.email_outlined,
                            'البريد',
                            company.email!,
                            fgColor,
                            mutedColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'عن الشركة',
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    company.description,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  if (company.certifications.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'الشهادات',
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
                      children: company.certifications
                          .map(
                            (cert) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSm,
                                ),
                                border: Border.all(
                                  color: AppColors.green.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_outlined,
                                    size: 14,
                                    color: AppColors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cert,
                                    style: const TextStyle(
                                      color: AppColors.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (companyOffers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'عروض الشركة',
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: companyOffers.map((offer) {
                            return SizedBox(
                              width: cardWidth,
                              child: OfferCard(
                                offer: offer,
                                avatarBase64: avatarBase64,
                                ownerRole: company.type,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OfferDetailScreen(
                                      offer: offer,
                                      onContact: onContact,
                                      avatarBase64: avatarBase64,
                                      ownerRole: company.type,
                                      isSaved: favorites.contains(offer.id),
                                      favorites: favorites,
                                      onToggleSaved: onToggleFavorite,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onContact?.call(company.name),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        'تواصل مع الشركة',
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

  Widget _row(IconData icon, String label, String value, Color fg, Color m) {
    return Row(
      children: [
        Icon(icon, size: 18, color: m),
        const SizedBox(width: 10),
        Text('$label: ', style: TextStyle(color: m, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
