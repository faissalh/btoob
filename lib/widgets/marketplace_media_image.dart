import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class MarketplaceMediaImage extends StatelessWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  const MarketplaceMediaImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(source);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
      );
    }
    try {
      return Image.memory(
        Uint8List.fromList(base64Decode(source)),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
      );
    } on FormatException {
      return const Icon(Icons.broken_image_outlined);
    }
  }
}
