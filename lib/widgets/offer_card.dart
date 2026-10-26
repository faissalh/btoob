import 'package:flutter/material.dart';

import '../l10n/post_card_localizations.dart';
import '../models/offer.dart';
import '../theme/app_theme.dart';
import 'post_card.dart';

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
    final localizations = postCardLocalizations(context);
    final isService = offer.type == 'خدمة';
    return PostCard(
      id: 'offer-${offer.id}',
      title: offer.title,
      publisherName: offer.companyName,
      ownerRole: ownerRole,
      avatarBase64: avatarBase64,
      avatarKey: ValueKey('offer-avatar-${offer.id}'),
      rating: offer.rating,
      isVerified: offer.isVerified,
      images: offer.imageBase64,
      typeIcon: isService
          ? Icons.build_circle_outlined
          : Icons.inventory_2_outlined,
      typeLabel: isService
          ? localizations.serviceType
          : offer.type == 'منتج'
          ? localizations.productType
          : offer.type,
      typeColor: isService ? AppColors.green : AppColors.accent,
      isFavorite: isFavorite,
      onFavoriteToggle: onFavoriteToggle,
      onDelete: onDelete,
      deleteKey: ValueKey('delete-offer-${offer.id}'),
      deleteTooltip: localizations.deleteOffer,
      primaryText: offer.price,
      primaryIcon: Icons.payments_outlined,
      description: offer.description,
      secondaryText: offer.minOrder == null
          ? null
          : localizations.minimumOrder(offer.minOrder!),
      onTap: onTap,
    );
  }
}
