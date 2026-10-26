import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/post_card_localizations.dart';

class PostMediaThumbnail extends StatefulWidget {
  final List<String> images;
  final IconData? typeIcon;
  final String? typeLabel;
  final Color typeColor;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final String? deleteTooltip;
  final VoidCallback? onDelete;
  final Key? deleteKey;

  const PostMediaThumbnail({
    super.key,
    required this.images,
    this.typeIcon,
    this.typeLabel,
    this.typeColor = const Color(0xFF2563EB),
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.deleteTooltip,
    this.onDelete,
    this.deleteKey,
  });

  @override
  State<PostMediaThumbnail> createState() => _PostMediaThumbnailState();
}

class _PostMediaThumbnailState extends State<PostMediaThumbnail> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = postCardLocalizations(context);
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) => _buildImage(
                widget.images[index],
                key: ValueKey('post-image-$index'),
              ),
            ),
            if (widget.typeIcon != null && widget.typeLabel != null)
              PositionedDirectional(
                start: 8,
                top: 8,
                child: Tooltip(
                  message: widget.typeLabel!,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.typeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.typeIcon, size: 17, color: Colors.white),
                  ),
                ),
              ),
            if (widget.onFavoriteToggle != null || widget.onDelete != null)
              PositionedDirectional(
                end: 8,
                top: 8,
                child: Column(
                  children: [
                    if (widget.onFavoriteToggle != null)
                      _OverlayAction(
                        tooltip: widget.isFavorite
                            ? localizations.removeSavedPost
                            : localizations.savePost,
                        icon: widget.isFavorite
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        onPressed: widget.onFavoriteToggle!,
                      ),
                    if (widget.onDelete != null) ...[
                      if (widget.onFavoriteToggle != null)
                        const SizedBox(height: 6),
                      _OverlayAction(
                        key: widget.deleteKey,
                        tooltip: widget.deleteTooltip ?? '',
                        icon: Icons.delete_outline,
                        onPressed: widget.onDelete!,
                      ),
                    ],
                  ],
                ),
              ),
            PositionedDirectional(
              end: 8,
              bottom: 8,
              child: DecoratedBox(
                key: const ValueKey('post-media-count-badge'),
                decoration: BoxDecoration(
                  color: const Color(0xCC0A3D91),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images.length}',
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String source, {required Key key}) {
    final uri = Uri.tryParse(source);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return Image.network(
        source,
        key: key,
        fit: BoxFit.cover,
        frameBuilder: _frameBuilder,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    final Uint8List? bytes;
    try {
      bytes = base64Decode(source);
    } on FormatException {
      return _fallback();
    }
    return Image.memory(
      bytes,
      key: key,
      fit: BoxFit.cover,
      frameBuilder: _frameBuilder,
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  Widget _frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        _placeholder(),
        AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: child,
        ),
        if (frame == null)
          const Center(
            child: SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0A3D91),
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallback() => const ColoredBox(
    color: Color(0xFFEAF1FC),
    child: Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: Color(0xFF0A3D91),
        size: 32,
      ),
    ),
  );

  Widget _placeholder() => const ColoredBox(color: Color(0xFFEAF1FC));
}

class _OverlayAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _OverlayAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.38),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 36,
            child: Icon(icon, size: 19, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
