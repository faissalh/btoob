import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/post_card_localizations.dart';
import '../models/offer.dart';
import 'company_detail_screen.dart';
import 'post_detail_screen.dart';

class OfferDetailScreen extends StatelessWidget {
  final Offer offer;
  final ValueChanged<String>? onContact;
  final String? avatarBase64;
  final String ownerRole;
  final bool isSaved;
  final Set<String> favorites;
  final ValueChanged<String>? onToggleSaved;

  const OfferDetailScreen({
    super.key,
    required this.offer,
    this.onContact,
    this.avatarBase64,
    this.ownerRole = 'مورد',
    this.isSaved = false,
    this.favorites = const {},
    this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    final company = MockData.getCompanyByName(offer.companyName);
    final localizations = postCardLocalizations(context);
    return PostDetailScreen(
      id: offer.id,
      isOffer: true,
      isService: offer.type == 'خدمة',
      title: offer.title,
      category: offer.category,
      description: offer.description,
      value: offer.price,
      minimumOrder: offer.minOrder,
      features: offer.features,
      countries: offer.countries,
      places: offer.places,
      publisherName: offer.companyName,
      publisherRole: ownerRole,
      avatarBase64: avatarBase64,
      publisherAvatarKey: const ValueKey('offer-detail-avatar'),
      isVerified: offer.isVerified || (company?.isVerified ?? false),
      rating: offer.rating > 0 ? offer.rating : company?.rating,
      images: postImageProviders(offer.imageBase64),
      isSaved: isSaved,
      onToggleSaved: onToggleSaved == null
          ? null
          : () => onToggleSaved!(offer.id),
      shareFeedback: localizations.shareOfferCopied,
      onContact: () => onContact?.call(offer.companyName),
      onSecondaryAction: () => onContact?.call(offer.companyName),
      onPublisherTap: company == null
          ? null
          : () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => CompanyDetailScreen(
                  company: company,
                  onContact: onContact,
                  avatarBase64: avatarBase64,
                  favorites: favorites,
                  onToggleFavorite: onToggleSaved,
                ),
              ),
            ),
    );
  }
}
