import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/purchase_request.dart';
import '../widgets/account_avatar.dart';
import '../widgets/marketplace_media_image.dart';

class RequestDetailScreen extends StatelessWidget {
  final PurchaseRequest request;
  final ValueChanged<String>? onContact;
  final String? avatarBase64;
  final String ownerRole;

  const RequestDetailScreen({
    super.key,
    required this.request,
    this.onContact,
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'تفاصيل طلب الشراء',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: request.status == 'مفتوح'
                          ? AppColors.green
                          : AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    request.status,
                    style: TextStyle(
                      color: request.status == 'مفتوح'
                          ? AppColors.green
                          : AppColors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              request.title,
              style: TextStyle(
                color: fgColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
            if (request.imageBase64.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: request.imageBase64.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: MarketplaceMediaImage(
                      source: request.imageBase64[index],
                      width: 190,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      AccountAvatar(
                        key: const ValueKey('request-detail-avatar'),
                        name: request.buyerName,
                        avatarBase64: avatarBase64,
                        role: ownerRole,
                        size: 34,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _row(
                          Icons.business,
                          'المشتري',
                          request.buyerName,
                          fgColor,
                          mutedColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _row(
                    Icons.person_outline,
                    'المسؤول',
                    request.contactPerson,
                    fgColor,
                    mutedColor,
                  ),
                  const SizedBox(height: 14),
                  _row(
                    Icons.inventory_2_outlined,
                    'الكمية',
                    request.quantity,
                    fgColor,
                    mutedColor,
                  ),
                  const SizedBox(height: 14),
                  _row(
                    Icons.location_on_outlined,
                    'الموقع',
                    request.location,
                    fgColor,
                    mutedColor,
                  ),
                  if (request.category != null) ...[
                    const SizedBox(height: 14),
                    _row(
                      Icons.category_outlined,
                      'الفئة',
                      request.category!,
                      fgColor,
                      mutedColor,
                    ),
                  ],
                  if (request.deadline != null) ...[
                    const SizedBox(height: 14),
                    _row(
                      Icons.schedule,
                      'آخر موعد',
                      request.deadline!,
                      fgColor,
                      mutedColor,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الميزانية',
                          style: TextStyle(color: mutedColor, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.budget,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (request.description != null) ...[
              const SizedBox(height: 20),
              Text(
                'تفاصيل الطلب',
                style: TextStyle(
                  color: fgColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                request.description!,
                style: TextStyle(color: mutedColor, fontSize: 14, height: 1.7),
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onContact?.call(request.buyerName),
                icon: const Icon(Icons.send_outlined),
                label: const Text(
                  'قدّم عرضك',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onContact?.call(request.buyerName),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text(
                  'تواصل مع المشتري',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
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
