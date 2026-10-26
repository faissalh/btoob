import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/purchase_request.dart';
import '../widgets/request_card.dart';
import '../widgets/common_widgets.dart';
import '../widgets/location_filter.dart';
import 'request_detail_screen.dart';
import '../models/user_profile.dart';
import '../widgets/account_avatar.dart';

class RequestsScreen extends StatefulWidget {
  final List<PurchaseRequest>? requests;
  final String? userId;
  final ValueChanged<String>? onContact;
  final Set<String> favorites;
  final ValueChanged<String>? onToggleFavorite;
  final Future<void> Function(String)? onDeleteRequest;
  final Map<String, UserProfile> profilesById;

  const RequestsScreen({
    super.key,
    this.requests,
    this.userId,
    this.onContact,
    this.favorites = const {},
    this.onToggleFavorite,
    this.onDeleteRequest,
    this.profilesById = const {},
  });
  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _filter = 'الكل';
  String _selectedCategory = 'الكل';
  Set<String> _selectedCountries = {};
  Set<String> _selectedCities = {};

  List<PurchaseRequest> get _filtered =>
      (widget.requests ?? MockData.purchaseRequests).where((request) {
        if (widget.userId != null && request.ownerId != widget.userId) {
          return false;
        }
        final matchesStatus = _filter == 'الكل' || request.status == _filter;
        final matchesCategory = MockData.matchesCategory(
          request.category,
          _selectedCategory,
        );
        final matchesCountry =
            _selectedCountries.isEmpty ||
            _selectedCountries.contains(request.country);
        final matchesCity =
            _selectedCities.isEmpty || _selectedCities.contains(request.city);
        return matchesStatus &&
            matchesCategory &&
            matchesCountry &&
            matchesCity;
      }).toList();

  Future<void> _confirmDelete(PurchaseRequest request) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف طلب الشراء؟'),
        content: Text('سيتم حذف «${request.title}» نهائياً من هذا الجهاز.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            key: ValueKey('confirm-delete-request-${request.id}'),
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('حذف الطلب'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    try {
      await widget.onDeleteRequest?.call(request.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حذف طلب الشراء')));
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
          child: Row(
            children: [
              _chip('الكل', isDark),
              const SizedBox(width: 8),
              _chip('مفتوح', isDark),
              const SizedBox(width: 8),
              _chip('مغلق', isDark),
              const Spacer(),
              Text(
                '${_filtered.length} طلب',
                style: TextStyle(
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: DropdownButtonFormField<String>(
            key: const ValueKey('requests-category-filter'),
            initialValue: _selectedCategory,
            decoration: const InputDecoration(labelText: 'الفئة'),
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
            key: const ValueKey('requests-location-filter'),
            title: 'موقع الطلب',
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
                  icon: Icons.inbox_outlined,
                  title: 'لا توجد طلبات شراء',
                )
              : ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 100),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) {
                    final r = _filtered[i];
                    final profile = resolveAccountProfile(
                      widget.profilesById,
                      userId: r.ownerId,
                      name: r.buyerName,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RequestCard(
                        request: r,
                        avatarBase64: profile?.avatarBase64,
                        ownerRole: profile?.role ?? 'مشتري',
                        onDelete: widget.userId != null
                            ? () => _confirmDelete(r)
                            : null,
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => RequestDetailScreen(
                              request: r,
                              avatarBase64: profile?.avatarBase64,
                              ownerRole: profile?.role ?? 'مشتري',
                              onContact: widget.onContact,
                              isSaved: widget.favorites.contains(
                                'request:${r.id}',
                              ),
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

  Widget _chip(String label, bool isDark) {
    final sel = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
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
