import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/offer.dart';
import '../models/purchase_request.dart';
import '../widgets/offer_card.dart';
import '../widgets/request_card.dart';
import '../widgets/company_card.dart';
import '../widgets/common_widgets.dart';
import 'offer_detail_screen.dart';
import 'company_detail_screen.dart';
import 'request_detail_screen.dart';
import '../models/user_profile.dart';
import '../widgets/account_avatar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToOffers;
  final VoidCallback? onNavigateToRequests;
  final VoidCallback? onNavigateToSuppliers;
  final VoidCallback? onPostOffer;
  final VoidCallback? onPostRequest;
  final List<Offer> offers;
  final List<PurchaseRequest> requests;
  final ValueChanged<String>? onContact;
  final Set<String> favorites;
  final ValueChanged<String>? onToggleFavorite;
  final Map<String, UserProfile> profilesById;

  const HomeScreen({
    super.key,
    this.onNavigateToOffers,
    this.onNavigateToRequests,
    this.onNavigateToSuppliers,
    this.onPostOffer,
    this.onPostRequest,
    this.offers = const [],
    this.requests = const [],
    this.onContact,
    this.favorites = const {},
    this.onToggleFavorite,
    this.profilesById = const {},
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heroAC;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroAC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _heroAC, curve: Curves.easeOut));
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroAC, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _heroAC.forward();
    });
  }

  @override
  void dispose() {
    _heroAC.dispose();
    super.dispose();
  }

  void _showPostOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('طلب شراء'),
              onTap: () {
                Navigator.pop(sheetContext);
                widget.onPostRequest?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer_outlined),
              title: const Text('نشر عرض أو منتج'),
              onTap: () {
                Navigator.pop(sheetContext);
                widget.onPostOffer?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHero(isDark)),
        SliverToBoxAdapter(child: _buildStats(isDark)),
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'أحدث العروض',
            actionText: 'عرض الكل',
            onAction: widget.onNavigateToOffers,
          ),
        ),
        SliverToBoxAdapter(child: _buildOffersGrid()),
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'طلبات تبحث عن مورد',
            actionText: 'عرض الكل',
            onAction: widget.onNavigateToRequests,
          ),
        ),
        SliverToBoxAdapter(child: _buildRequestsList()),
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'موردون ومصانع',
            actionText: 'عرض الكل',
            onAction: widget.onNavigateToSuppliers,
          ),
        ),
        SliverToBoxAdapter(child: _buildSuppliersList()),
        SliverToBoxAdapter(child: _buildFooter(isDark)),
      ],
    );
  }

  Widget _buildHero(bool isDark) {
    return FadeTransition(
      opacity: _heroFade,
      child: SlideTransition(
        position: _heroSlide,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [const Color(0xFF1E3A5F), const Color(0xFF0F1724)]
                  : [AppColors.accent, AppColors.accent2],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.store_mall_directory_outlined,
                size: 40,
                color: Colors.white70,
              ),
              const SizedBox(height: 12),
              const Text(
                'سوق الجملة B2B للخليج',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'نقطة تجمع المشترين مع الموردين والمصانع — انشر طلب شراء، أو اعرض منتجاتك، وتواصل مباشرة.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _heroBtn(
                    Icons.search,
                    'تصفح الموردين',
                    false,
                    widget.onNavigateToSuppliers,
                  ),
                  _heroBtn(
                    Icons.search,
                    'ابحث أو اطلب',
                    true,
                    _showPostOptions,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroBtn(
    IconData icon,
    String label,
    bool filled,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: filled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: filled ? AppColors.accent : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? AppColors.accent : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkPanel : AppColors.panel,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
      ),
      child: Row(
        children: [
          _stat(8, 'عرض ومنتج', isDark),
          _div(isDark),
          _stat(3, 'طلب شراء', isDark),
          _div(isDark),
          _stat(6, 'مورد ومصنع', isDark),
          _div(isDark),
          _stat(6, 'دول خليجية', isDark),
        ],
      ),
    );
  }

  Widget _stat(int v, String l, bool isDark) => Expanded(
    child: AnimatedCounter(value: v, label: l),
  );
  Widget _div(bool isDark) => Container(
    width: 1,
    height: 32,
    color: isDark ? AppColors.darkLine : AppColors.line,
  );

  Widget _buildOffersGrid() {
    final items = (widget.offers.isEmpty ? MockData.offers : widget.offers)
        .take(4)
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.58,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final o = items[i];
          final profile = resolveAccountProfile(
            widget.profilesById,
            userId: o.ownerId,
            name: o.companyName,
          );
          final ownerRole =
              profile?.role ??
              MockData.getCompanyByName(o.companyName)?.type ??
              'مورد';
          return OfferCard(
            offer: o,
            avatarBase64: profile?.avatarBase64,
            ownerRole: ownerRole,
            isFavorite: widget.favorites.contains(o.id),
            onFavoriteToggle: () => widget.onToggleFavorite?.call(o.id),
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => OfferDetailScreen(
                  offer: o,
                  onContact: widget.onContact,
                  avatarBase64: profile?.avatarBase64,
                  ownerRole: ownerRole,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children:
            (widget.requests.isEmpty
                    ? MockData.purchaseRequests
                    : widget.requests)
                .take(2)
                .map((r) {
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RequestDetailScreen(
                            request: r,
                            onContact: widget.onContact,
                            avatarBase64: profile?.avatarBase64,
                            ownerRole: profile?.role ?? 'مشتري',
                          ),
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
      ),
    );
  }

  Widget _buildSuppliersList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: MockData.companies.take(3).map((c) {
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
                context,
                MaterialPageRoute(
                  builder: (_) => CompanyDetailScreen(
                    company: c,
                    onContact: widget.onContact,
                    avatarBase64: profile?.avatarBase64,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    final m = isDark ? AppColors.darkMuted : AppColors.muted;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'سوق — سوق الجملة B2B للخليج',
            style: TextStyle(
              color: m,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'تطبيق سوق الجملة للخليج · جميع الحقوق محفوظة ٢٠٢٦',
            style: TextStyle(color: m.withValues(alpha: 0.6), fontSize: 11),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
