import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../data/gulf_locations.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/account_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _emailC;
  late final TextEditingController _websiteC;
  late final TextEditingController _bioC;
  final _imagePicker = ImagePicker();
  late String _country;
  late String _city;
  String? _avatarBase64;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _nameC = TextEditingController(text: profile.fullName);
    _phoneC = TextEditingController(text: profile.phone);
    _emailC = TextEditingController(text: profile.email);
    _websiteC = TextEditingController(text: profile.website);
    _bioC = TextEditingController(text: profile.bio);
    _country = GulfLocations.citiesByCountry.containsKey(profile.country)
        ? profile.country
        : GulfLocations.countries.first;
    _city = GulfLocations.citiesByCountry[_country]!.contains(profile.city)
        ? profile.city
        : GulfLocations.citiesByCountry[_country]!.first;
    _avatarBase64 = profile.avatarBase64;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _websiteC.dispose();
    _bioC.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _avatarBase64 = base64Encode(bytes));
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر اختيار الصورة، حاول مرة أخرى')),
      );
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final profile = widget.profile.copyWith(
      fullName: _nameC.text.trim(),
      phone: _phoneC.text.trim(),
      email: _emailC.text.trim(),
      country: _country,
      city: _city,
      website: _websiteC.text.trim(),
      bio: _bioC.text.trim(),
      avatarBase64: _avatarBase64,
      clearAvatar: _avatarBase64 == null,
    );
    if (!mounted) return;
    Navigator.pop(context, profile);
  }

  String? _validateEmail(String? value) {
    if (value == null ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'أدخل بريداً إلكترونياً صحيحاً';
    }
    return null;
  }

  String? _validateWebsite(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(
      value.trim().contains('://') ? value.trim() : 'https://${value.trim()}',
    );
    return uri == null || uri.host.isEmpty || !uri.host.contains('.')
        ? 'أدخل رابط موقع صحيحاً'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'تعديل الملف الشخصي',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    AccountAvatar(
                      name: _nameC.text,
                      avatarBase64: _avatarBase64,
                      role: widget.profile.role,
                      size: 108,
                    ),
                    PositionedDirectional(
                      bottom: 0,
                      end: 0,
                      child: IconButton.filled(
                        key: const ValueKey('profile-pick-avatar'),
                        onPressed: _pickAvatar,
                        tooltip: 'تغيير الصورة',
                        icon: const Icon(Icons.camera_alt_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const ValueKey('profile-name'),
                controller: _nameC,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'يرجى إدخال الاسم'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: widget.profile.username,
                readOnly: true,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'اسم المستخدم'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('profile-email'),
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneC,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'رقم الجوال'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const ValueKey('profile-country'),
                initialValue: _country,
                decoration: const InputDecoration(labelText: 'الدولة'),
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
                key: ValueKey('profile-city-$_country'),
                initialValue: _city,
                decoration: const InputDecoration(labelText: 'المدينة'),
                items: GulfLocations.citiesByCountry[_country]!
                    .map(
                      (city) =>
                          DropdownMenuItem(value: city, child: Text(city)),
                    )
                    .toList(),
                onChanged: (city) {
                  if (city != null) setState(() => _city = city);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('profile-website'),
                controller: _websiteC,
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'رابط الموقع الإلكتروني',
                  hintText: 'example.com',
                ),
                validator: _validateWebsite,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('profile-bio'),
                controller: _bioC,
                maxLength: 300,
                minLines: 3,
                maxLines: 5,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'نبذة عنك',
                  hintText: 'اكتب نبذة قصيرة عنك أو عن نشاطك...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('حفظ التعديلات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
