import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import 'local_user_store.dart';
import 'supabase_config.dart';

class SupabaseUserStore extends LocalUserStore {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<UserProfile?> restoreSession() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _loadProfile(user);
  }

  @override
  Future<UserProfile?> loadProfile(String userId) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null || authUser.id != userId) {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return row == null ? null : _profileFromRow(row);
    }
    return _loadProfile(authUser);
  }

  @override
  Future<List<UserProfile>> loadProfiles() async {
    if (_client.auth.currentUser == null) return [];
    final rows = await _client.from('profiles').select();
    final activeId = _client.auth.currentUser?.id;
    return rows.map((row) {
      final email = row['id'] == activeId
          ? (_client.auth.currentUser?.email ?? '')
          : '';
      return _profileFromRow(row, email: email);
    }).toList();
  }

  @override
  Future<bool> login(String username, String password) async {
    await _client.auth.signInWithPassword(
      email: username.trim(),
      password: password,
    );
    return true;
  }

  @override
  Future<UserProfile> createAccount({
    required String fullName,
    required String username,
    required String password,
    required String phone,
    required String email,
    required String country,
    required String city,
    required String website,
    required String role,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'username': username.trim().toLowerCase(),
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'country': country,
        'city': city,
        'website': website.trim(),
        'role': role,
      },
    );
    final user = response.user;
    if (user == null) throw StateError('لم يُرجع Supabase بيانات الحساب');
    if (response.session == null) {
      throw StateError(
        'تم إنشاء الحساب، لكن لم تبدأ جلسة الدخول. عطّل تأكيد البريد '
        'الإلكتروني من إعدادات Supabase Auth ثم سجّل الدخول.',
      );
    }
    return _loadProfile(user);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final user = _client.auth.currentUser;
    if (user == null || user.id != profile.id) {
      throw StateError('يجب تسجيل الدخول لتعديل الملف الشخصي');
    }

    String? avatarPath;
    final current = await _client
        .from('profiles')
        .select('avatar_path')
        .eq('id', profile.id)
        .single();
    avatarPath = current['avatar_path'] as String?;

    final avatar = profile.avatarBase64;
    if (avatar == null || avatar.isEmpty) {
      avatarPath = null;
    } else if (!avatar.startsWith('http://') &&
        !avatar.startsWith('https://')) {
      final bytes = base64Decode(avatar);
      const extension = 'jpg';
      avatarPath =
          '${profile.id}/${DateTime.now().microsecondsSinceEpoch}.$extension';
      await _client.storage
          .from('avatars')
          .uploadBinary(
            avatarPath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );
    }

    if (profile.email.isNotEmpty && profile.email != user.email) {
      await _client.auth.updateUser(UserAttributes(email: profile.email));
    }

    await _client
        .from('profiles')
        .update({
          'full_name': profile.fullName,
          'phone': profile.phone,
          'country': profile.country,
          'city': profile.city,
          'website': profile.website,
          'bio': profile.bio,
          'avatar_path': avatarPath,
        })
        .eq('id', profile.id);

    if (current['avatar_path'] != null &&
        avatarPath != current['avatar_path']) {
      await _client.storage.from('avatars').remove([
        current['avatar_path'] as String,
      ]);
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    final user = _client.auth.currentUser;
    if (user == null || user.id != userId) {
      throw StateError('لا يمكن حذف حساب غير مسجل الدخول');
    }
    await _client.rpc('delete_current_user');
    await _client.auth.signOut(scope: SignOutScope.local);
  }

  @override
  Future<void> logout() => _client.auth.signOut();

  Future<UserProfile> _loadProfile(User user) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) {
      throw StateError('تعذر العثور على الملف الشخصي المرتبط بالحساب');
    }
    return _profileFromRow(row, email: user.email ?? '');
  }

  UserProfile _profileFromRow(Map<String, dynamic> row, {String email = ''}) {
    final avatarPath = row['avatar_path'] as String?;
    final avatarUrl = avatarPath == null
        ? null
        : _client.storage.from('avatars').getPublicUrl(avatarPath);
    return UserProfile(
      id: row['id'] as String,
      fullName: row['full_name'] as String,
      username: row['username'] as String,
      phone: row['phone'] as String? ?? '',
      email: email,
      country: row['country'] as String? ?? '',
      city: row['city'] as String? ?? '',
      website: row['website'] as String? ?? '',
      bio: row['bio'] as String? ?? '',
      role: row['role'] as String? ?? 'مشتري',
      avatarBase64: avatarUrl,
    );
  }
}
