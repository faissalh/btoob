import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/company.dart';
import '../widgets/company_card.dart';
import '../widgets/common_widgets.dart';
import '../widgets/location_filter.dart';
import 'company_detail_screen.dart';
import '../models/user_profile.dart';
import '../widgets/account_avatar.dart';

class SuppliersScreen extends StatefulWidget {
  final ValueChanged<String>? onContact;
  final Map<String, UserProfile> profilesById;
  final Set<String> favorites;
  final ValueChanged<String>? onToggleFavorite;

  const SuppliersScreen({
    super.key,
    this.onContact,
    this.profilesById = const {},
    this.favorites = const {},
    this.onToggleFavorite,
  });
  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _sc = TextEditingController();
  String _q = '';
  String _type = 'الكل';
  String _selectedCategory = 'الكل';
  Set<String> _selectedCountries = {};
  Set<String> _selectedCities = {};

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  List<Company> get _filtered => MockData.companies.where((c) {
    final companyOffers = MockData.getCompanyOffers(c.name);
    final matchesCategory =
        _selectedCategory == 'الكل' ||
        (companyOffers.isEmpty
            ? _selectedCategory == 'أخرى'
            : companyOffers.any(
                (offer) =>
                    MockData.matchesCategory(offer.category, _selectedCategory),
              ));
    final matchesSearch =
        _q.isEmpty ||
        c.name.contains(_q) ||
        c.description.contains(_q) ||
        c.country.contains(_q) ||
        c.city.contains(_q) ||
        companyOffers.any((offer) => offer.category.contains(_q));
    final matchesType = _type == 'الكل' || c.type == _type;
    final matchesCountry =
        _selectedCountries.isEmpty || _selectedCountries.contains(c.country);
    final matchesCity =
        _selectedCities.isEmpty || _selectedCities.contains(c.city);
    return matchesSearch &&
        matchesType &&
        matchesCategory &&
        matchesCountry &&
        matchesCity;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SearchField(
            hint: 'ابحث عن مورد أو مصنع...',
            controller: _sc,
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              _chip('الكل', isDark),
              const SizedBox(width: 8),
              _chip('مورد', isDark),
              const SizedBox(width: 8),
              _chip('مصنع', isDark),
              const Spacer(),
              Text(
                '${_filtered.length} شركة',
                style: TextStyle(color: mutedColor, fontSize: 13),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: DropdownButtonFormField<String>(
            key: const ValueKey('supplier-category-filter'),
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'فئة المورد أو المصنع',
            ),
            items: MockData.categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (category) {
              if (category != null) {
                setState(() => _selectedCategory = category);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: LocationFilterButton(
            key: const ValueKey('supplier-city-filter'),
            title: 'موقع المورد',
            countries: _selectedCountries,
            cities: _selectedCities,
            onChanged: (selection) => setState(() {
              _selectedCountries = selection.countries;
              _selectedCities = selection.cities;
            }),
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const EmptyState(
                  icon: Icons.business_outlined,
                  title: 'لا توجد نتائج',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) {
                    final c = _filtered[i];
                    final profile = resolveAccountProfile(
                      widget.profilesById,
                      name: c.name,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CompanyCard(
                        company: c,
                        avatarBase64: profile?.avatarBase64,
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => CompanyDetailScreen(
                              company: c,
                              onContact: widget.onContact,
                              avatarBase64: profile?.avatarBase64,
                              favorites: widget.favorites,
                              onToggleFavorite: widget.onToggleFavorite,
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

  Widget _chip(String label, bool isDark) {
    final sel = _type == label;
    return GestureDetector(
      onTap: () => setState(() => _type = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? AppColors.accent
              : (isDark ? AppColors.darkPanel : AppColors.panel),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: sel
                ? AppColors.accent
                : (isDark ? AppColors.darkLine : AppColors.line),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel
                ? Colors.white
                : (isDark ? AppColors.darkMuted : AppColors.muted),
            fontSize: 13,
            fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
