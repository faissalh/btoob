import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../l10n/post_card_localizations.dart';
import '../models/purchase_request.dart';
import 'company_detail_screen.dart';
import 'post_detail_screen.dart';

class RequestDetailScreen extends StatelessWidget {
  final PurchaseRequest request;
  final ValueChanged<String>? onContact;
  final String? avatarBase64;
  final String ownerRole;
  final bool isSaved;
  final Set<String> favorites;
  final ValueChanged<String>? onToggleSaved;

  const RequestDetailScreen({
    super.key,
    required this.request,
    this.onContact,
    this.avatarBase64,
    this.ownerRole = 'مشتري',
    this.isSaved = false,
    this.favorites = const {},
    this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    final company = MockData.getCompanyByName(request.buyerName);
    final localizations = postCardLocalizations(context);
    final countries = request.places.isNotEmpty
        ? request.places.keys.toList()
        : [request.country];
    final places = request.places.isNotEmpty
        ? request.places
        : {
            request.country: request.city.isEmpty
                ? const <String>[]
                : [request.city],
          };

    return PostDetailScreen(
      id: request.id,
      isOffer: false,
      isService: false,
      title: request.title,
      category: request.category ?? '',
      description: request.description,
      value: request.budget,
      countries: countries,
      places: places,
      publisherName: request.buyerName,
      publisherRole: ownerRole,
      avatarBase64: avatarBase64,
      publisherAvatarKey: const ValueKey('request-detail-avatar'),
      isVerified: company?.isVerified ?? false,
      rating: company?.rating,
      images: postImageProviders(request.imageBase64),
      requestStatus: request.status,
      contactPerson: request.contactPerson,
      quantity: request.quantity,
      deadline: request.deadline,
      isSaved: isSaved,
      onToggleSaved: onToggleSaved == null
          ? null
          : () => onToggleSaved!('request:${request.id}'),
      shareFeedback: localizations.shareRequestCopied,
      onContact: () => onContact?.call(request.buyerName),
      onSecondaryAction: () => onContact?.call(request.buyerName),
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
