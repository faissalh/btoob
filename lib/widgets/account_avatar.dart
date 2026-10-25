import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class AccountAvatar extends StatelessWidget {
  final String name;
  final String? avatarBase64;
  final String role;
  final double size;

  const AccountAvatar({
    super.key,
    required this.name,
    this.avatarBase64,
    this.role = 'مشتري',
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final strongBorder = role.contains('مورد') || role.contains('مصنع');
    final borderWidth = strongBorder ? 3.0 : 1.2;
    final avatarUri = avatarBase64 == null ? null : Uri.tryParse(avatarBase64!);
    final avatarUrl =
        avatarUri != null &&
        (avatarUri.scheme == 'http' || avatarUri.scheme == 'https');
    final imageBytes = avatarUrl ? null : _decodeAvatar();
    final color = role.contains('مصنع') ? AppColors.green : AppColors.accent;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: strongBorder ? 0.9 : 0.35),
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: avatarUrl
            ? Image.network(
                avatarBase64!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallback(color),
              )
            : imageBytes == null
            ? _fallback(color)
            : Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallback(color),
              ),
      ),
    );
  }

  Uint8List? _decodeAvatar() {
    if (avatarBase64 == null || avatarBase64!.isEmpty) return null;
    try {
      return base64Decode(avatarBase64!);
    } on FormatException {
      return null;
    }
  }

  Widget _fallback(Color color) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);
    final label = initials.map((part) => part.characters.first).join();
    return ColoredBox(
      color: color.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          label.isEmpty ? '؟' : label,
          maxLines: 1,
          style: TextStyle(
            color: color,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

UserProfile? resolveAccountProfile(
  Map<String, UserProfile> profiles, {
  String? userId,
  required String name,
}) {
  if (userId != null && profiles.containsKey(userId)) return profiles[userId];
  for (final profile in profiles.values) {
    if (profile.fullName == name || profile.username == name) return profile;
  }
  return null;
}
