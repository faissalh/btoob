import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/gulf_locations.dart';
import '../data/local_user_store.dart';
import '../data/supabase_config.dart';
import '../data/supabase_user_store.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  static const _demoUsername = 'demo';
  static const _demoPassword = 'demo123';

  final _formKey = GlobalKey<FormState>();
  final LocalUserStore _userStore = SupabaseConfig.isInitialized
      ? SupabaseUserStore()
      : LocalUserStore();
  final _userC = TextEditingController();
  final _passC = TextEditingController();
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _emailC = TextEditingController();
  final _websiteC = TextEditingController();
  bool _isLogin = true;
  bool _obscure = true;
  bool _isSubmitting = false;
  String _role = 'مشتري';
  String _country = 'السعودية';
  String? _city = 'الرياض';
  late final AnimationController _ac;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    _userC.dispose();
    _passC.dispose();
    _nameC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _websiteC.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    await _ac.reverse();
    if (!mounted) return;
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
    await _ac.forward();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    try {
      final authenticated = _isLogin
          ? await _userStore.login(_userC.text.trim(), _passC.text)
          : await _createAccount();
      if (!mounted) return;
      if (!authenticated) {
        _showMessage(
          SupabaseConfig.isInitialized
              ? 'بيانات الدخول غير صحيحة، تحقق من البريد الإلكتروني وكلمة المرور'
              : 'بيانات الدخول غير صحيحة، تحقق من اسم المستخدم وكلمة المرور',
        );
        return;
      }
      _showMessage(
        _isLogin ? 'تم تسجيل الدخول بنجاح' : 'تم إنشاء الحساب بنجاح',
        color: AppColors.green,
      );
      Navigator.pop(context, true);
    } on StateError catch (error) {
      if (mounted) _showMessage(error.message);
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } on PostgrestException catch (error) {
      if (mounted) {
        _showMessage(
          error.code == '23505'
              ? 'اسم المستخدم مستخدم من قبل'
              : 'تعذر حفظ الحساب في Supabase: ${error.message}',
        );
      }
    } on Exception catch (error) {
      if (mounted) _showMessage('تعذر إكمال العملية: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _createAccount() async {
    await _userStore.createAccount(
      fullName: _nameC.text.trim(),
      username: _userC.text.trim(),
      password: _passC.text,
      phone: _phoneC.text.trim(),
      email: _emailC.text.trim(),
      country: _country,
      city: _city!,
      website: _websiteC.text.trim(),
      role: _role,
    );
    return true;
  }

  void _showMessage(String message, {Color? color}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  String? _required(String? value, String message) =>
      value == null || value.trim().isEmpty ? message : null;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'أدخل بريداً إلكترونياً صحيحاً';
    }
    return null;
  }

  String? _validateWebsite(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال رابط الموقع الإلكتروني';
    }
    final uri = Uri.tryParse(
      value.trim().contains('://') ? value.trim() : 'https://${value.trim()}',
    );
    if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
      return 'أدخل رابط موقع صحيحاً';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.darkFg : AppColors.fg;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        title: Text(
          _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fade,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accent2],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'سوق',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkPanel2 : AppColors.bg2,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      children: [
                        _tab('دخول', _isLogin, mutedColor, _toggle),
                        _tab('حساب جديد', !_isLogin, mutedColor, _toggle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isLogin && !SupabaseConfig.isInitialized) ...[
                    _demoCredentials(),
                    const SizedBox(height: 16),
                  ],
                  if (!_isLogin) ...[
                    TextFormField(
                      key: const ValueKey('auth-name'),
                      controller: _nameC,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        hintText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          _required(value, 'يرجى إدخال الاسم الكامل'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    key: const ValueKey('auth-username'),
                    controller: _userC,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: _isLogin && SupabaseConfig.isInitialized
                          ? 'البريد الإلكتروني'
                          : 'اسم المستخدم',
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                    validator: (value) {
                      final isEmailLogin =
                          _isLogin && SupabaseConfig.isInitialized;
                      final required = _required(
                        value,
                        isEmailLogin
                            ? 'يرجى إدخال البريد الإلكتروني'
                            : 'يرجى إدخال اسم المستخدم',
                      );
                      if (required != null || _isLogin) return required;
                      if (value!.trim().length < 3) {
                        return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('auth-password'),
                    controller: _passC,
                    obscureText: _obscure,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (value) {
                      final required = _required(
                        value,
                        'يرجى إدخال كلمة المرور',
                      );
                      if (required != null || _isLogin) return required;
                      if (value!.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneC,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        hintText: 'رقم الجوال (اختياري)',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('auth-email'),
                      controller: _emailC,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        hintText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('auth-website'),
                      controller: _websiteC,
                      keyboardType: TextInputType.url,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        hintText: 'رابط الموقع الإلكتروني',
                        prefixIcon: Icon(Icons.language),
                      ),
                      validator: _validateWebsite,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: const ValueKey('auth-country'),
                      initialValue: _country,
                      decoration: const InputDecoration(
                        labelText: 'الدولة',
                        prefixIcon: Icon(Icons.public),
                      ),
                      items: GulfLocations.countries
                          .map(
                            (country) => DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            ),
                          )
                          .toList(),
                      onChanged: (country) {
                        if (country == null) return;
                        setState(() {
                          _country = country;
                          _city = GulfLocations.citiesByCountry[country]!.first;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('auth-city-$_country'),
                      initialValue: _city,
                      decoration: const InputDecoration(
                        labelText: 'المدينة',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: GulfLocations.citiesByCountry[_country]!
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ),
                          )
                          .toList(),
                      onChanged: (city) => setState(() => _city = city),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'نوع الحساب',
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _roleBtn(
                            'مشتري',
                            Icons.shopping_cart_outlined,
                            isDark,
                            fgColor,
                            mutedColor,
                            borderColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _roleBtn(
                            'مورد',
                            Icons.store_outlined,
                            isDark,
                            fgColor,
                            mutedColor,
                            borderColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          _isSubmitting
                              ? 'جارٍ المعالجة...'
                              : (_isLogin ? 'دخول' : 'إنشاء حساب'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isLogin)
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(color: mutedColor, fontSize: 13),
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

  Widget _demoCredentials() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'بيانات الحساب التجريبي',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text('اسم المستخدم: demo'),
        const Text('كلمة المرور: demo123'),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () {
              _userC.text = _demoUsername;
              _passC.text = _demoPassword;
            },
            child: const Text('استخدام بيانات الحساب'),
          ),
        ),
      ],
    ),
  );

  Widget _tab(String label, bool active, Color muted, VoidCallback onTap) =>
      Expanded(
        child: GestureDetector(
          onTap: active ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : muted,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _roleBtn(
    String role,
    IconData icon,
    bool isDark,
    Color fg,
    Color muted,
    Color border,
  ) {
    final selected = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentSoft
              : (isDark ? AppColors.darkPanel2 : AppColors.panel2),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: selected ? AppColors.accent : border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.accent : muted, size: 28),
            const SizedBox(height: 6),
            Text(
              role,
              style: TextStyle(
                color: selected ? AppColors.accent : fg,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
