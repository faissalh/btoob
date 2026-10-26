import 'package:flutter/material.dart';

import '../l10n/post_card_localizations.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'edit_profile_screen.dart';
import '../widgets/account_avatar.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeToggle;
  final Locale? locale;
  final ValueChanged<Locale>? onLocaleChanged;
  final bool isLoggedIn;
  final Future<void> Function() onLogin;
  final Future<void> Function() onLogout;
  final Future<void> Function() onDeleteAccount;
  final int offerCount;
  final int requestCount;
  final int messageCount;
  final UserProfile? userProfile;
  final Future<void> Function(UserProfile)? onSaveProfile;
  final VoidCallback onViewOffers;
  final VoidCallback onViewRequests;
  final VoidCallback onViewMessages;
  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeToggle,
    this.locale,
    this.onLocaleChanged,
    required this.isLoggedIn,
    required this.onLogin,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.offerCount,
    required this.requestCount,
    required this.messageCount,
    this.userProfile,
    this.onSaveProfile,
    required this.onViewOffers,
    required this.onViewRequests,
    required this.onViewMessages,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _deleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الحساب؟'),
        content: const Text(
          'سيتم حذف حسابك وكل عروضك وطلباتك ورسائلك المرتبطة به. '
          'لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            key: const ValueKey('confirm-delete-account'),
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;

    try {
      await widget.onDeleteAccount();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف الحساب وبياناته')));
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _editProfile() async {
    final profile = widget.userProfile;
    if (profile == null) return;
    final updated = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile)),
    );
    if (updated == null || !mounted) return;
    try {
      await widget.onSaveProfile?.call(updated);
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم تحديث الملف الشخصي')));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = postCardLocalizations(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkPanel : AppColors.panel;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;
    final fgColor = isDark ? AppColors.darkFg : AppColors.fg;
    final profile = widget.userProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          AccountAvatar(
            key: const ValueKey('profile-avatar'),
            name: profile?.fullName ?? 'زائر',
            avatarBase64: profile?.avatarBase64,
            role: profile?.role ?? 'مشتري',
            size: 84,
          ),
          const SizedBox(height: 16),
          Text(
            widget.isLoggedIn ? (profile?.fullName ?? 'المستخدم') : 'زائر',
            style: TextStyle(
              color: fgColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.isLoggedIn && profile != null)
            Text(
              '${profile.role} · ${profile.city}، ${profile.country}',
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
          if (widget.isLoggedIn && profile != null) ...[
            const SizedBox(height: 6),
            Text(
              '@${profile.username}',
              textDirection: TextDirection.ltr,
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
            if (profile.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                profile.bio,
                textAlign: TextAlign.center,
                style: TextStyle(color: fgColor, fontSize: 14, height: 1.5),
              ),
            ],
          ],
          const SizedBox(height: 24),
          if (!widget.isLoggedIn) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final authenticated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute<bool>(builder: (_) => const AuthScreen()),
                  );
                  if (mounted && authenticated == true) {
                    await widget.onLogin();
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (widget.isLoggedIn && profile != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('edit-profile'),
                onPressed: _editProfile,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('تعديل الملف الشخصي'),
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius),
                side: BorderSide(color: borderColor),
              ),
              child: Column(
                children: [
                  _tile(
                    Icons.email_outlined,
                    'البريد الإلكتروني',
                    profile.email,
                    fgColor,
                    mutedColor,
                  ),
                  Divider(height: 1, color: borderColor),
                  _tile(
                    Icons.language,
                    'الموقع الإلكتروني',
                    profile.website.isEmpty ? 'غير مضاف' : profile.website,
                    fgColor,
                    mutedColor,
                  ),
                  if (profile.phone.isNotEmpty) ...[
                    Divider(height: 1, color: borderColor),
                    _tile(
                      Icons.phone_outlined,
                      'رقم الجوال',
                      profile.phone,
                      fgColor,
                      mutedColor,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          _sectionTitle('الإعدادات', fgColor),
          const SizedBox(height: 8),
          Material(
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              side: BorderSide(color: borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.dark_mode_outlined,
                    color: mutedColor,
                    size: 22,
                  ),
                  title: Text(
                    'الوضع الداكن',
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: widget.isDarkMode,
                  onChanged: widget.onDarkModeToggle,
                  activeThumbColor: AppColors.accent,
                ),
                Divider(height: 1, color: borderColor),
                PopupMenuButton<Locale>(
                  tooltip: localizations.languageLabel,
                  onSelected: widget.onLocaleChanged,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: const Locale('ar'),
                      child: Text(localizations.arabicLanguageName),
                    ),
                    PopupMenuItem(
                      value: const Locale('en'),
                      child: Text(localizations.englishLanguageName),
                    ),
                  ],
                  child: ListTile(
                    leading: Icon(Icons.language, color: mutedColor, size: 22),
                    title: Text(
                      localizations.languageLabel,
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      (widget.locale ?? Localizations.localeOf(context))
                                  .languageCode ==
                              'en'
                          ? localizations.englishLanguageName
                          : localizations.arabicLanguageName,
                      style: TextStyle(color: mutedColor, fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_back_ios,
                      size: 14,
                      color: mutedColor,
                    ),
                  ),
                ),
                Divider(height: 1, color: borderColor),
                _tile(
                  Icons.notifications_outlined,
                  'الإشعارات',
                  'مفعّلة',
                  fgColor,
                  mutedColor,
                ),
              ],
            ),
          ),
          if (widget.isLoggedIn) ...[
            const SizedBox(height: 20),
            _sectionTitle('نشاطي', fgColor),
            const SizedBox(height: 8),
            Material(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius),
                side: BorderSide(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _tile(
                    Icons.local_offer_outlined,
                    'عروضي',
                    '${widget.offerCount} عرض',
                    fgColor,
                    mutedColor,
                    onTap: widget.onViewOffers,
                  ),
                  Divider(height: 1, color: borderColor),
                  _tile(
                    Icons.shopping_cart_outlined,
                    'طلبات الشراء',
                    '${widget.requestCount} طلب',
                    fgColor,
                    mutedColor,
                    onTap: widget.onViewRequests,
                  ),
                  Divider(height: 1, color: borderColor),
                  _tile(
                    Icons.bookmark_border,
                    'المحفوظات',
                    '0 محفوظ',
                    fgColor,
                    mutedColor,
                  ),
                  Divider(height: 1, color: borderColor),
                  _tile(
                    Icons.chat_bubble_outline,
                    'الرسائل',
                    '${widget.messageCount} رسالة',
                    fgColor,
                    mutedColor,
                    onTap: widget.onViewMessages,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _sectionTitle('حول التطبيق', fgColor),
          const SizedBox(height: 8),
          Material(
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              side: BorderSide(color: borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: mutedColor,
                    size: 22,
                  ),
                  title: Text(
                    'عن سوق',
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'سوق الجملة B2B للخليج',
                    style: TextStyle(color: mutedColor, fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.arrow_back_ios,
                    size: 14,
                    color: mutedColor,
                  ),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'سوق',
                    applicationVersion: '1.0.0',
                    children: [
                      const Text(
                        'سوق الجملة B2B للخليج — نقطة تجمع المشترين مع الموردين والمصانع.',
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: borderColor),
                _tile(
                  Icons.privacy_tip_outlined,
                  'سياسة الخصوصية',
                  null,
                  fgColor,
                  mutedColor,
                ),
              ],
            ),
          ),
          if (widget.isLoggedIn) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await widget.onLogout();
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('تم تسجيل الخروج')),
                  );
                },
                icon: const Icon(Icons.logout, color: AppColors.red),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: AppColors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.red),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('delete-account'),
                onPressed: _deleteAccount,
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('حذف الحساب'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'سوق v1.0.0',
            style: TextStyle(
              color: mutedColor.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, Color c) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Text(
      t,
      style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w700),
    ),
  );

  Widget _tile(
    IconData icon,
    String title,
    String? sub,
    Color fg,
    Color m, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: m, size: 22),
      title: Text(
        title,
        style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: sub != null
          ? Text(sub, style: TextStyle(color: m, fontSize: 12))
          : null,
      trailing: Icon(Icons.arrow_back_ios, size: 14, color: m),
      onTap: onTap,
    );
  }
}
