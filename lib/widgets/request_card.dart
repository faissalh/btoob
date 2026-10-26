import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/post_card_localizations.dart';
import '../models/purchase_request.dart';
import '../theme/app_theme.dart';
import 'post_card.dart';

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
    final localizations = postCardLocalizations(context);
    final company = MockData.getCompanyByName(request.buyerName);
    final isOpen = request.status == 'مفتوح';
    final statusLabel = isOpen
        ? localizations.openRequest
        : request.status == 'مغلق'
        ? localizations.closedRequest
        : request.status;
    final mutedColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkMuted
        : AppColors.muted;

    return PostCard(
      id: 'request-${request.id}',
      title: request.title,
      publisherName: request.buyerName,
      ownerRole: ownerRole,
      avatarBase64: avatarBase64,
      avatarKey: ValueKey('request-avatar-${request.id}'),
      rating: company?.rating,
      isVerified: company?.isVerified ?? false,
      images: request.imageBase64,
      onDelete: onDelete,
      deleteKey: ValueKey('delete-request-${request.id}'),
      deleteTooltip: localizations.deleteRequest,
      primaryText: request.budget,
      primaryIcon: Icons.payments_outlined,
      description: request.description,
      secondaryText: localizations.requestQuantity(request.quantity),
      additionalDetails: [
        PostStatusBadge(label: statusLabel, isOpen: isOpen),
        if (request.category != null)
          _RequestCategoryLabel(category: request.category!, color: mutedColor),
        PostDetailLabel(
          icon: Icons.person_outline,
          text: request.contactPerson,
        ),
        PostDetailLabel(
          icon: Icons.location_on_outlined,
          text: request.location,
        ),
        if (request.deadline != null)
          PostDetailLabel(
            icon: Icons.schedule,
            text: localizations.requestDeadline(request.deadline!),
            color: AppColors.amber,
          ),
      ],
      onTap: onTap,
    );
  }
}

class _RequestCategoryLabel extends StatelessWidget {
  final String category;
  final Color color;

  const _RequestCategoryLabel({required this.category, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
    ),
    child: Text(category, style: TextStyle(color: color, fontSize: 11)),
  );
}
