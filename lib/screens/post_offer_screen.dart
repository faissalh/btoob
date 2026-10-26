import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../data/gulf_locations.dart';
import '../models/offer.dart';
import '../widgets/location_filter.dart';
import '../widgets/places_selector.dart';

class PostOfferScreen extends StatefulWidget {
  final String ownerId;
  final String ownerName;

  const PostOfferScreen({
    super.key,
    this.ownerId = 'demo',
    this.ownerName = 'أحمد محمد',
  });
  @override
  State<PostOfferScreen> createState() => _PostOfferScreenState();
}

class _PostOfferScreenState extends State<PostOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _priceC = TextEditingController();
  final _minC = TextEditingController();
  final _descC = TextEditingController();
  final _imagePicker = ImagePicker();
  String _type = 'منتج';
  String _cat = 'مواد بناء';
  Set<String> _countries = {};
  Set<String> _cities = {};
  Map<String, List<String>> _places = {};
  List<XFile> _images = [];
  bool _submitting = false;

  @override
  void dispose() {
    _titleC.dispose();
    _priceC.dispose();
    _minC.dispose();
    _descC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_countries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار دولة واحدة على الأقل'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    final imageBase64 = await Future.wait(
      _images.map((image) async => base64Encode(await image.readAsBytes())),
    );
    if (!mounted) return;
    Navigator.pop(
      context,
      Offer(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleC.text.trim(),
        type: _type,
        price: _priceC.text.trim(),
        minOrder: _minC.text.trim().isEmpty ? null : _minC.text.trim(),
        category: _cat,
        countries: _countries.toList(),
        places: {
          for (final country in _countries)
            country: List.unmodifiable(_places[country] ?? const <String>[]),
        },
        companyName: widget.ownerName,
        rating: 0,
        description: _descC.text.trim(),
        colorIndex: 0,
        ownerId: widget.ownerId,
        imageBase64: imageBase64,
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage(imageQuality: 85);
      if (!mounted || images.isEmpty) return;
      setState(() {
        _images = [
          ..._images,
          ...images.where(
            (image) => !_images.any((selected) => selected.path == image.path),
          ),
        ];
      });
    } on PlatformException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر اختيار الصور، يرجى المحاولة مرة أخرى'),
          ),
        );
      }
    }
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
        title: const Text(
          'نشر عرض جديد',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('نوع العرض', fgColor),
              const SizedBox(height: 8),
              Row(
                children: [
                  _typeChip(
                    'منتج',
                    Icons.inventory_2_outlined,
                    isDark,
                    fgColor,
                    mutedColor,
                    borderColor,
                  ),
                  const SizedBox(width: 12),
                  _typeChip(
                    'خدمة',
                    Icons.build_circle_outlined,
                    isDark,
                    fgColor,
                    mutedColor,
                    borderColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _label('عنوان العرض', fgColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleC,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: 'مثال: رمل وحصى مكسر — توريد يومي',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'يرجى إدخال العنوان' : null,
              ),
              const SizedBox(height: 20),
              _label('الفئة', fgColor),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _cat,
                items: MockData.categories
                    .where((c) => c != 'الكل')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _cat = v!),
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 20),
              _label('السعر', fgColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceC,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: 'مثال: من 32 ر.س/متر مكعب',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'يرجى إدخال السعر' : null,
              ),
              const SizedBox(height: 20),
              _label('الحد الأدنى للطلب (اختياري)', fgColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _minC,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(hintText: 'مثال: 100 وحدة'),
              ),
              const SizedBox(height: 20),
              _label('الدول المستهدفة', fgColor),
              const SizedBox(height: 8),
              LocationFilterButton(
                key: const ValueKey('post-offer-location'),
                title: 'دول ومدن التوريد',
                countries: _countries,
                cities: _cities,
                allowAll: false,
                onChanged: (selection) => setState(() {
                  _countries = selection.countries;
                  _cities = selection.cities;
                  _places = {
                    for (final country in selection.countries)
                      country: List.unmodifiable(
                        (GulfLocations.citiesByCountry[country] ??
                                const <String>[])
                            .where(selection.cities.contains)
                            .toList(),
                      ),
                  };
                }),
              ),
              const SizedBox(height: 10),
              PlacesSelector(
                key: ValueKey('post-offer-places-${_countries.join('-')}'),
                countries: _countries.toList(),
                places: _places,
                onChanged: (places) => setState(() => _places = places),
              ),
              const SizedBox(height: 20),
              _label('وصف العرض', fgColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descC,
                textDirection: TextDirection.rtl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'اكتب وصفاً تفصيلياً للعرض...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'يرجى إدخال الوصف' : null,
              ),
              const SizedBox(height: 30),
              _label('صور المنتج (اختياري)', fgColor),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey('post-offer-add-images'),
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('إضافة صور متعددة'),
              ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'الصور المرفقة (${_images.length})',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final image in _images)
                      _OfferSelectedImage(
                        key: ValueKey(image.path),
                        image: image,
                        onRemove: () => setState(
                          () => _images.removeWhere(
                            (item) => item.path == image.path,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'نشر العرض',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t, Color c) => Text(
    t,
    style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w600),
  );

  Widget _typeChip(
    String label,
    IconData icon,
    bool isDark,
    Color fg,
    Color muted,
    Color border,
  ) {
    final sel = _type == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel
                ? AppColors.accentSoft
                : (isDark ? AppColors.darkPanel2 : AppColors.panel2),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: sel ? AppColors.accent : border,
              width: sel ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: sel ? AppColors.accent : muted, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: sel ? AppColors.accent : fg,
                  fontSize: 14,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferSelectedImage extends StatefulWidget {
  const _OfferSelectedImage({
    super.key,
    required this.image,
    required this.onRemove,
  });

  final XFile image;
  final VoidCallback onRemove;

  @override
  State<_OfferSelectedImage> createState() => _OfferSelectedImageState();
}

class _OfferSelectedImageState extends State<_OfferSelectedImage> {
  late final Future<Uint8List> _imageBytes = widget.image.readAsBytes();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: FutureBuilder<Uint8List>(
              future: _imageBytes,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const ColoredBox(
                    color: AppColors.panel2,
                    child: Icon(Icons.broken_image_outlined),
                  );
                }
                if (!snapshot.hasData) {
                  return const ColoredBox(
                    color: AppColors.panel2,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              },
            ),
          ),
          Positioned(
            top: 2,
            left: 2,
            child: IconButton(
              tooltip: 'إزالة الصورة',
              onPressed: widget.onRemove,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                minimumSize: const Size(28, 28),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
