import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/post_card_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/account_avatar.dart';

class PostDetailScreen extends StatefulWidget {
  final String id;
  final bool isOffer;
  final bool isService;
  final String title;
  final String category;
  final String? description;
  final String? value;
  final String? minimumOrder;
  final List<String> features;
  final List<String> countries;
  final Map<String, List<String>> places;
  final String publisherName;
  final String publisherRole;
  final String? avatarBase64;
  final Key? publisherAvatarKey;
  final bool isVerified;
  final double? rating;
  final List<ImageProvider<Object>> images;
  final String? requestStatus;
  final String? contactPerson;
  final String? quantity;
  final String? deadline;
  final bool isSaved;
  final VoidCallback? onToggleSaved;
  final VoidCallback? onShare;
  final VoidCallback? onContact;
  final VoidCallback? onSecondaryAction;
  final String? shareFeedback;
  final VoidCallback? onPublisherTap;

  const PostDetailScreen({
    super.key,
    required this.id,
    required this.isOffer,
    required this.isService,
    required this.title,
    required this.category,
    this.description,
    this.value,
    this.minimumOrder,
    this.features = const [],
    this.countries = const [],
    this.places = const {},
    required this.publisherName,
    this.publisherRole = 'مورد',
    this.avatarBase64,
    this.publisherAvatarKey,
    this.isVerified = false,
    this.rating,
    this.images = const [],
    this.requestStatus,
    this.contactPerson,
    this.quantity,
    this.deadline,
    this.isSaved = false,
    this.onToggleSaved,
    this.onShare,
    this.onContact,
    this.onSecondaryAction,
    this.shareFeedback,
    this.onPublisherTap,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final PageController _pageController;
  late bool _isSaved = widget.isSaved;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant PostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSaved != widget.isSaved) {
      _isSaved = widget.isSaved;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleSaved() {
    final localizations = postCardLocalizations(context);
    setState(() => _isSaved = !_isSaved);
    widget.onToggleSaved?.call();
    if (widget.onToggleSaved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved
                ? localizations.savedPostMessage
                : localizations.removedSavedPostMessage,
          ),
        ),
      );
    }
  }

  void _share() {
    widget.onShare?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.shareFeedback ??
              postCardLocalizations(context).shareOfferCopied,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = postCardLocalizations(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.darkBg : const Color(0xFFF4F6FA);
    final cardColor = isDark ? AppColors.darkPanel : Colors.white;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final foreground = isDark ? AppColors.darkFg : AppColors.fg;
    final muted = isDark ? AppColors.darkMuted : AppColors.muted;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      if (widget.images.isEmpty) _buildToolbar(localizations),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsetsDirectional.only(
                            bottom: 20,
                            start: _horizontalPadding(context),
                            end: _horizontalPadding(context),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (widget.images.isNotEmpty) ...[
                                _buildGallery(localizations),
                                if (widget.images.length > 1)
                                  _buildThumbnails(),
                              ],
                              const SizedBox(height: 18),
                              if (widget.requestStatus != null) ...[
                                _requestStatusBadge(
                                  widget.requestStatus!,
                                  localizations,
                                ),
                                const SizedBox(height: 10),
                              ],
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 24,
                                  height: 1.35,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (widget.category.isNotEmpty)
                                    _infoChip(
                                      Icons.category_outlined,
                                      widget.category,
                                      muted,
                                    ),
                                  if (widget.isOffer)
                                    _infoChip(
                                      widget.isService
                                          ? Icons.build_circle_outlined
                                          : Icons.inventory_2_outlined,
                                      widget.isService
                                          ? localizations.serviceDetailsLabel
                                          : localizations.productDetailsLabel,
                                      widget.isService
                                          ? AppColors.green
                                          : _primary,
                                    ),
                                ],
                              ),
                              if (_hasDescription) ...[
                                const SizedBox(height: 14),
                                _sectionTitle(
                                  widget.isOffer
                                      ? localizations.offerDescription
                                      : localizations.requestDescription,
                                  foreground,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.description!.trim(),
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 14,
                                    height: 1.65,
                                  ),
                                ),
                              ],
                              if (widget.value != null ||
                                  widget.minimumOrder != null) ...[
                                const SizedBox(height: 18),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.value != null)
                                      Expanded(
                                        child: _valueCard(
                                          context,
                                          label: widget.isOffer
                                              ? localizations.priceLabel
                                              : localizations.budgetLabel,
                                          value: widget.value!,
                                          icon: Icons.payments_outlined,
                                          valueColor: AppColors.green,
                                          cardColor: cardColor,
                                          borderColor: borderColor,
                                          muted: muted,
                                        ),
                                      ),
                                    if (widget.value != null &&
                                        widget.minimumOrder != null)
                                      const SizedBox(width: 10),
                                    if (widget.minimumOrder != null)
                                      Expanded(
                                        child: _valueCard(
                                          context,
                                          label:
                                              localizations.minimumOrderLabel,
                                          value: widget.minimumOrder!,
                                          icon: Icons.inventory_2_outlined,
                                          valueColor: foreground,
                                          cardColor: cardColor,
                                          borderColor: borderColor,
                                          muted: muted,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              if (widget.features.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                _sectionTitle(
                                  localizations.featuresLabel,
                                  foreground,
                                ),
                                const SizedBox(height: 8),
                                for (final feature in widget.features)
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      bottom: 8,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          color: AppColors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            feature,
                                            style: TextStyle(
                                              color: foreground,
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                              if (widget.contactPerson != null ||
                                  widget.quantity != null ||
                                  widget.deadline != null) ...[
                                const SizedBox(height: 18),
                                _requestInfoCard(
                                  context,
                                  cardColor: cardColor,
                                  borderColor: borderColor,
                                  foreground: foreground,
                                  muted: muted,
                                  localizations: localizations,
                                ),
                              ],
                              const SizedBox(height: 20),
                              _sectionTitle(
                                localizations.targetPlacesLabel,
                                foreground,
                              ),
                              const SizedBox(height: 10),
                              _buildTargetPlaces(
                                context,
                                foreground: foreground,
                                muted: muted,
                                cardColor: cardColor,
                                borderColor: borderColor,
                                localizations: localizations,
                              ),
                              const SizedBox(height: 20),
                              _sectionTitle(
                                widget.isOffer
                                    ? localizations.supplierLabel
                                    : localizations.buyerLabel,
                                foreground,
                              ),
                              const SizedBox(height: 10),
                              _publisherCard(
                                context,
                                cardColor: cardColor,
                                borderColor: borderColor,
                                foreground: foreground,
                                muted: muted,
                                localizations: localizations,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(
              context,
              localizations: localizations,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasDescription =>
      widget.description != null && widget.description!.trim().isNotEmpty;

  static const Color _primary = Color(0xFF0A3D91);

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 360 ? 14 : 20;
  }

  Widget _buildToolbar(AppLocalizations localizations) {
    return Row(
      children: [
        IconButton(
          key: const ValueKey('post-detail-back'),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.maybePop(context),
          icon: const BackButtonIcon(),
        ),
        const Spacer(),
        IconButton(
          tooltip: localizations.sharePost,
          onPressed: _share,
          icon: const Icon(Icons.share_outlined),
        ),
        IconButton(
          tooltip: _isSaved
              ? localizations.removeSavedPost
              : localizations.savePost,
          onPressed: _toggleSaved,
          icon: Icon(
            _isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: _isSaved ? _primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildGallery(AppLocalizations localizations) {
    return AspectRatio(
      key: ValueKey('post-detail-gallery-${widget.id}'),
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: const BorderRadiusDirectional.vertical(
          bottom: Radius.circular(18),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentImage = index),
              itemBuilder: (context, index) => Image(
                image: widget.images[index],
                fit: BoxFit.cover,
                frameBuilder: _imageFrameBuilder,
                errorBuilder: (context, error, stackTrace) => _imageFallback(),
              ),
            ),
            PositionedDirectional(
              start: 8,
              top: 8,
              child: _imageAction(
                key: const ValueKey('post-detail-back'),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.maybePop(context),
                child: const BackButtonIcon(),
              ),
            ),
            PositionedDirectional(
              end: 8,
              top: 8,
              child: Row(
                children: [
                  _imageAction(
                    tooltip: localizations.sharePost,
                    onPressed: _share,
                    child: const Icon(Icons.share_outlined),
                  ),
                  const SizedBox(width: 8),
                  _imageAction(
                    tooltip: _isSaved
                        ? localizations.removeSavedPost
                        : localizations.savePost,
                    onPressed: _toggleSaved,
                    child: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isOffer)
              PositionedDirectional(
                start: 10,
                bottom: 10,
                child: Tooltip(
                  message: widget.isService
                      ? localizations.serviceDetailsLabel
                      : localizations.productDetailsLabel,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: widget.isService ? AppColors.green : _primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isService
                          ? Icons.build_circle_outlined
                          : Icons.inventory_2_outlined,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ),
            PositionedDirectional(
              end: 10,
              bottom: 10,
              child: DecoratedBox(
                key: const ValueKey('post-detail-image-counter'),
                decoration: BoxDecoration(
                  color: const Color(0xCC0A3D91),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  child: Text(
                    '${_currentImage + 1}/${widget.images.length}',
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.images.length > 1)
              PositionedDirectional(
                bottom: 15,
                start: 0,
                end: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < widget.images.length; index++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsetsDirectional.only(end: 5),
                        width: index == _currentImage ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index == _currentImage
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnails() {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        padding: const EdgeInsetsDirectional.only(top: 10, bottom: 4),
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _currentImage;
          return GestureDetector(
            key: ValueKey('post-detail-thumbnail-${widget.id}-$index'),
            onTap: () {
              setState(() => _currentImage = index);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? _primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: widget.images[index],
                  fit: BoxFit.cover,
                  frameBuilder: _imageFrameBuilder,
                  errorBuilder: (context, error, stackTrace) =>
                      _imageFallback(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imageFrameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        _imagePlaceholder(),
        AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          child: child,
        ),
        if (frame == null)
          const Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
            ),
          ),
      ],
    );
  }

  Widget _imagePlaceholder() => const ColoredBox(
    color: Color(0xFFEAF1FC),
    child: Center(child: Icon(Icons.image_outlined, color: _primary, size: 30)),
  );

  Widget _imageFallback() => const ColoredBox(
    color: Color(0xFFEAF1FC),
    child: Center(
      child: Icon(Icons.broken_image_outlined, color: _primary, size: 34),
    ),
  );

  Widget _imageAction({
    Key? key,
    required String tooltip,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Tooltip(
      key: key,
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.38),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 38,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white, size: 20),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color foreground) => Text(
    title,
    style: TextStyle(
      color: foreground,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _valueCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color valueColor,
    required Color cardColor,
    required Color borderColor,
    required Color muted,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: valueColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestStatusBadge(String status, AppLocalizations localizations) {
    final isOpen = status == 'مفتوح' || status == 'Open' || status == 'open';
    final label = isOpen
        ? localizations.openRequestStatus
        : status == 'مغلق' || status == 'Closed' || status == 'closed'
        ? localizations.closedRequestStatus
        : status;
    final color = isOpen ? AppColors.green : AppColors.red;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _requestInfoCard(
    BuildContext context, {
    required Color cardColor,
    required Color borderColor,
    required Color foreground,
    required Color muted,
    required AppLocalizations localizations,
  }) {
    final rows = <(IconData, String, String)>[
      if (widget.contactPerson != null)
        (
          Icons.person_outline,
          localizations.contactPersonLabel,
          widget.contactPerson!,
        ),
      if (widget.quantity != null)
        (
          Icons.inventory_2_outlined,
          localizations.quantityLabel,
          widget.quantity!,
        ),
      if (widget.countries.isNotEmpty)
        (
          Icons.location_on_outlined,
          localizations.locationLabel,
          widget.countries.join(' · '),
        ),
      if (widget.deadline != null)
        (Icons.schedule, localizations.deadlineLabel, widget.deadline!),
    ];
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            Row(
              children: [
                Icon(rows[index].$1, color: muted, size: 18),
                const SizedBox(width: 9),
                Text(
                  '${rows[index].$2}: ',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                Expanded(
                  child: Text(
                    rows[index].$3,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTargetPlaces(
    BuildContext context, {
    required Color foreground,
    required Color muted,
    required Color cardColor,
    required Color borderColor,
    required AppLocalizations localizations,
  }) {
    final countries = widget.countries.toSet().toList();
    if (countries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        for (final country in countries)
          Container(
            width: double.infinity,
            margin: const EdgeInsetsDirectional.only(bottom: 8),
            padding: const EdgeInsetsDirectional.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.public, color: _primary, size: 19),
                const SizedBox(width: 8),
                SizedBox(
                  width: 88,
                  child: Text(
                    country,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        (widget.places[country] ?? const <String>[]).isEmpty
                        ? [
                            _cityChip(
                              localizations.allCities,
                              foreground,
                              muted,
                            ),
                          ]
                        : widget.places[country]!
                              .map((city) => _cityChip(city, foreground, muted))
                              .toList(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cityChip(String city, Color foreground, Color muted) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A3D91).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(city, style: TextStyle(color: muted, fontSize: 11)),
    );
  }

  Widget _publisherCard(
    BuildContext context, {
    required Color cardColor,
    required Color borderColor,
    required Color foreground,
    required Color muted,
    required AppLocalizations localizations,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: ValueKey('post-detail-publisher-${widget.id}'),
        onTap: widget.onPublisherTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsetsDirectional.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              AccountAvatar(
                key:
                    widget.publisherAvatarKey ??
                    ValueKey('post-detail-publisher-avatar-${widget.id}'),
                name: widget.publisherName,
                avatarBase64: widget.avatarBase64,
                role: widget.publisherRole,
                size: 44,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.publisherName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: foreground,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (widget.isVerified) ...[
                          const SizedBox(width: 4),
                          Tooltip(
                            message: localizations.verifiedPublisher,
                            child: const Icon(
                              Icons.verified,
                              color: _primary,
                              size: 17,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.rating.toString(),
                            style: TextStyle(
                              color: foreground,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: muted,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context, {
    required AppLocalizations localizations,
    required Color cardColor,
    required Color borderColor,
  }) {
    final contactLabel = widget.isOffer
        ? localizations.contactSupplier
        : localizations.contactBuyer;
    final actionLabel = widget.isOffer
        ? localizations.requestQuote
        : localizations.makeOffer;
    return Material(
      color: cardColor,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              width: double.infinity,
              padding: EdgeInsetsDirectional.fromSTEB(
                _horizontalPadding(context),
                10,
                _horizontalPadding(context),
                10,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      key: const ValueKey('post-detail-contact'),
                      onPressed: widget.onContact,
                      icon: Icon(
                        widget.isOffer
                            ? Icons.chat_bubble_outline
                            : Icons.send_outlined,
                        size: 18,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(contactLabel),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('post-detail-secondary-action'),
                      onPressed: widget.onSecondaryAction,
                      icon: const Icon(Icons.request_quote_outlined, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(actionLabel),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<ImageProvider<Object>> postImageProviders(Iterable<String> sources) {
  return sources.map<ImageProvider<Object>>((source) {
    final uri = Uri.tryParse(source);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(source);
    }
    final encoded = source.startsWith('data:')
        ? source.substring(source.indexOf(',') + 1)
        : source;
    try {
      return MemoryImage(Uint8List.fromList(base64Decode(encoded)));
    } on FormatException {
      return MemoryImage(Uint8List(0));
    }
  }).toList();
}
