import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class PostMediaThumbnail extends StatelessWidget {
  final List<String> images;
  final double width;
  final double height;

  const PostMediaThumbnail({
    super.key,
    required this.images,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(images.first);
    final imageUrl =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    Uint8List? imageBytes;
    if (!imageUrl) {
      try {
        imageBytes = base64Decode(images.first);
      } on FormatException {
        imageBytes = null;
      }
    }

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl)
              Image.network(
                images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFFEAF1FC),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF0A3D91),
                  ),
                ),
              )
            else if (imageBytes == null)
              const ColoredBox(
                color: Color(0xFFEAF1FC),
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF0A3D91),
                ),
              )
            else
              Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: Color(0xFFEAF1FC)),
                      AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: child,
                      ),
                      if (frame == null)
                        const Center(
                          child: SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0A3D91),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFFEAF1FC),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF0A3D91),
                  ),
                ),
              ),
            PositionedDirectional(
              end: 6,
              bottom: 6,
              child: DecoratedBox(
                key: const ValueKey('post-media-count-badge'),
                decoration: BoxDecoration(
                  color: const Color(0xCC0A3D91),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  child: Text(
                    '1/${images.length}',
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
}
