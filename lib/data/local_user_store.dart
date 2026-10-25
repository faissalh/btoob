import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class LocalUserStore {
  static const _accountsKey = 'local_user_accounts';
  static const _activeUserKey = 'active_user_id';
  static const _legacyLoginKey = 'demo_account_logged_in';
  static const _demoProfileKey = 'user_profile_demo';
  static const _demoAccountDeletedKey = 'demo_account_deleted';

  Future<List<Map<String, Object?>>> _readAccounts(
    SharedPreferences preferences,
  ) async {
    final json = preferences.getString(_accountsKey);
    if (json == null) return [];
    return (jsonDecode(json) as List)
        .map((item) => Map<String, Object?>.from(item as Map))
        .toList();
  }

  String _passwordHash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  Future<UserProfile?> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    final activeId = preferences.getString(_activeUserKey);
    if (activeId == null && (preferences.getBool(_legacyLoginKey) ?? false)) {
      final migrated = await preferences.setString(_activeUserKey, 'demo');
      if (!migrated) throw StateError('تعذرت استعادة جلسة الحساب التجريبي');
      return loadProfile('demo');
    }
    if (activeId == null) return null;
    final profile = await loadProfile(activeId);
    if (profile == null) throw StateError('تعذر العثور على الحساب المحفوظ');
    return profile;
  }

  Future<UserProfile?> loadProfile(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    if (userId == 'demo') {
      final json = preferences.getString(_demoProfileKey);
      if (json == null) return UserProfile.demo();
      return UserProfile.fromJson(
        Map<String, Object?>.from(jsonDecode(json) as Map),
      );
    }
    for (final account in await _readAccounts(preferences)) {
      if ((account['profile'] as Map?)?['id'] == userId) {
        return UserProfile.fromJson(
          Map<String, Object?>.from(account['profile']! as Map),
        );
      }
    }
    return null;
  }

  Future<List<UserProfile>> loadProfiles() async {
    final preferences = await SharedPreferences.getInstance();
    final profiles = (await _readAccounts(preferences))
        .map(
          (account) => UserProfile.fromJson(
            Map<String, Object?>.from(account['profile']! as Map),
          ),
        )
        .toList();
    profiles.add(await loadProfile('demo') ?? UserProfile.demo());
    return profiles;
  }

  Future<bool> login(String username, String password) async {
    final preferences = await SharedPreferences.getInstance();
    if (username == 'demo' && password == 'demo123') {
      if (preferences.getBool(_demoAccountDeletedKey) ?? false) return false;
      await _setSession(preferences, 'demo');
      return true;
    }
    final account = (await _readAccounts(preferences)).where(
      (item) =>
          item['username'] == username &&
          item['passwordHash'] ==
              _passwordHash(password, item['salt']! as String),
    );
    if (account.isEmpty) return false;
    final profile = Map<String, Object?>.from(account.first['profile']! as Map);
    await _setSession(preferences, profile['id']! as String);
    return true;
  }

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
    final preferences = await SharedPreferences.getInstance();
    final accounts = await _readAccounts(preferences);
    if (username == 'demo' ||
        accounts.any((account) => account['username'] == username)) {
      throw StateError('اسم المستخدم مستخدم من قبل');
    }
    if (accounts.any((account) => account['email'] == email)) {
      throw StateError('البريد الإلكتروني مسجل من قبل');
    }

    final profile = UserProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fullName: fullName,
      username: username,
      phone: phone,
      email: email,
      country: country,
      city: city,
      website: website,
      role: role,
    );
    accounts.add({
      'username': username,
      'email': email,
      'salt': profile.id,
      'passwordHash': _passwordHash(password, profile.id),
      'profile': profile.toJson(),
    });
    final saved = await preferences.setString(
      _accountsKey,
      jsonEncode(accounts),
    );
    if (!saved) throw StateError('تعذر حفظ الحساب على هذا الجهاز');
    await _setSession(preferences, profile.id);
    return profile;
  }

  Future<void> saveProfile(UserProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    if (profile.id == 'demo') {
      final saved = await preferences.setString(
        _demoProfileKey,
        jsonEncode(profile.toJson()),
      );
      if (!saved) throw StateError('تعذر حفظ الملف الشخصي على هذا الجهاز');
      return;
    }

    final accounts = await _readAccounts(preferences);
    if (accounts.any(
      (account) =>
          account['email'] == profile.email &&
          (account['profile'] as Map?)?['id'] != profile.id,
    )) {
      throw StateError('البريد الإلكتروني مسجل في حساب آخر');
    }
    final index = accounts.indexWhere(
      (account) => (account['profile'] as Map?)?['id'] == profile.id,
    );
    if (index == -1) throw StateError('الحساب غير موجود على هذا الجهاز');
    accounts[index]['email'] = profile.email;
    accounts[index]['profile'] = profile.toJson();
    final saved = await preferences.setString(
      _accountsKey,
      jsonEncode(accounts),
    );
    if (!saved) throw StateError('تعذر حفظ الملف الشخصي على هذا الجهاز');
  }

  Future<void> deleteAccount(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final activeUserId = preferences.getString(_activeUserKey);
    if (activeUserId != userId &&
        !(activeUserId == null &&
            userId == 'demo' &&
            (preferences.getBool(_legacyLoginKey) ?? false))) {
      throw StateError('لا يمكن حذف حساب غير مسجل الدخول');
    }

    if (userId == 'demo') {
      final accountMarkedDeleted = await preferences.setBool(
        _demoAccountDeletedKey,
        true,
      );
      if (!accountMarkedDeleted) {
        throw StateError('تعذر حذف الحساب التجريبي على هذا الجهاز');
      }
      final profileRemoved = await preferences.remove(_demoProfileKey);
      if (!profileRemoved) {
        throw StateError('تعذر حذف بيانات الملف الشخصي على هذا الجهاز');
      }
    } else {
      final accounts = await _readAccounts(preferences);
      final remainingAccounts = accounts
          .where((account) => (account['profile'] as Map?)?['id'] != userId)
          .toList();
      if (remainingAccounts.length == accounts.length) {
        throw StateError('الحساب غير موجود على هذا الجهاز');
      }
      final saved = await preferences.setString(
        _accountsKey,
        jsonEncode(remainingAccounts),
      );
      if (!saved) throw StateError('تعذر حذف الحساب على هذا الجهاز');
    }

    final sessionRemoved = await preferences.remove(_activeUserKey);
    if (!sessionRemoved) throw StateError('تعذر إنهاء جلسة الحساب بعد الحذف');
    final loggedOut = await preferences.setBool(_legacyLoginKey, false);
    if (!loggedOut) throw StateError('تعذر إنهاء جلسة الحساب بعد الحذف');
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_activeUserKey);
    final saved = await preferences.setBool(_legacyLoginKey, false);
    if (!saved) throw StateError('تعذر إنهاء جلسة الدخول على هذا الجهاز');
  }

  Future<void> _setSession(SharedPreferences preferences, String userId) async {
    final saved = await preferences.setString(_activeUserKey, userId);
    if (!saved) throw StateError('تعذر حفظ جلسة الدخول على هذا الجهاز');
    final legacySaved = await preferences.setBool(_legacyLoginKey, true);
    if (!legacySaved) throw StateError('تعذر تحديث حالة الدخول على هذا الجهاز');
  }
}
