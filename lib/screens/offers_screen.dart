import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/offer.dart';
import '../widgets/offer_card.dart';
import '../widgets/common_widgets.dart';
import '../widgets/location_filter.dart';
import 'offer_detail_screen.dart';
import '../models/user_profile.dart';
import '../widgets/account_avatar.dart';

class OffersScreen extends StatefulWidget {
  final List<Offer>? offers;
  final String? userId;
  final ValueChanged<String>? onContact;
  final Set<String> favorites;
  final ValueChanged<String>? onToggleFavorite;
  final Future<void> Function(String)? onDeleteOffer;
  final Map<String, UserProfile> profilesById;
  const OffersScreen({
    super.key,
    this.offers,
    this.userId,
    this.onContact,
    this.favorites = const {},
    this.onToggleFavorite,
    this.onDeleteOffer,
    this.profilesById = const {},
  });

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final _sc = TextEditingController();
  String _cat = 'الكل';
  String _q = '';
  Set<String> _selectedCountries = {};
  Set<String> _selectedCities = {};

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  List<Offer> get _filtered => (widget.offers ?? MockData.offers).where((o) {
    if (widget.userId != null && o.ownerId != widget.userId) return false;
    final mc = MockData.matchesCategory(o.category, _cat);
    final company = MockData.getCompanyByName(o.companyName);
    final ms =
        _q.isEmpty ||
        o.title.contains(_q) ||
        o.companyName.contains(_q) ||
        o.category.contains(_q) ||
        (company != null &&
            (company.country.contains(_q) || company.city.contains(_q)));
    final matchesCountry =
        _selectedCountries.isEmpty ||
        (company != null && _selectedCountries.contains(company.country));
    final matchesCity =
        _selectedCities.isEmpty ||
        (company != null && _selectedCities.contains(company.city));
    return mc && ms && matchesCountry && matchesCity;
  }).toList();

  Future<void> _confirmDelete(Offer offer) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العرض؟'),
        content: Text('سيتم حذف «${offer.title}» نهائياً من هذا الجهاز.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            key: ValueKey('confirm-delete-offer-${offer.id}'),
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('حذف العرض'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    try {
      await widget.onDeleteOffer?.call(offer.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حذف العرض')));
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SearchField(
            hint: 'ابحث في العروض والمنتجات...',
            controller: _sc,
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: MockData.categories.length,
            itemBuilder: (ctx, i) {
              final cat = MockData.categories[i];
              final sel = cat == _cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: sel,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _cat = cat),
                  selectedColor: AppColors.accentSoft,
                  labelStyle: TextStyle(
                    color: sel
                        ? AppColors.accent
                        : (isDark ? AppColors.darkMuted : AppColors.muted),
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: sel
                        ? AppColors.accent.withValues(alpha: 0.3)
                        : (isDark ? AppColors.darkLine : AppColors.line),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: LocationFilterButton(
            key: const ValueKey('offers-location-filter'),
            title: 'موقع المورد',
            countries: _selectedCountries,
            cities: _selectedCities,
            onChanged: (selection) => setState(() {
              _selectedCountries = selection.countries;
              _selectedCities = selection.cities;
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              '${_filtered.length} عرض',
              style: TextStyle(
                color: isDark ? AppColors.darkMuted : AppColors.muted,
                fontSize: 13,
              ),
            ),
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off,
                  title: 'لا توجد نتائج',
                  subtitle: 'جرب تغيير كلمة البحث أو الفئة',
                )
              : ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 100),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) {
                    final o = _filtered[i];
                    final profile = resolveAccountProfile(
                      widget.profilesById,
                      userId: o.ownerId,
                      name: o.companyName,
                    );
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 12),
                      child: OfferCard(
                        offer: o,
                        avatarBase64: profile?.avatarBase64,
                        ownerRole:
                            profile?.role ??
                            MockData.getCompanyByName(o.companyName)?.type ??
                            'مورد',
                        isFavorite: widget.favorites.contains(o.id),
                        onFavoriteToggle: () =>
                            widget.onToggleFavorite?.call(o.id),
                        onDelete: widget.userId != null
                            ? () => _confirmDelete(o)
                            : null,
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => OfferDetailScreen(
                              offer: o,
                              avatarBase64: profile?.avatarBase64,
                              ownerRole:
                                  profile?.role ??
                                  MockData.getCompanyByName(o.companyName)
                                      ?.type ??
                                  'مورد',
                              onContact: widget.onContact,
                              isSaved: widget.favorites.contains(o.id),
                              favorites: widget.favorites,
                              onToggleSaved: widget.onToggleFavorite,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
