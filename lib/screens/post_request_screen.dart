import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../data/gulf_locations.dart';
import '../models/purchase_request.dart';
import '../widgets/places_selector.dart';

class PostRequestScreen extends StatefulWidget {
  final String ownerId;
  final String ownerName;

  const PostRequestScreen({
    super.key,
    this.ownerId = 'demo',
    this.ownerName = 'أحمد محمد',
  });
  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _qtyC = TextEditingController();
  final _budgetC = TextEditingController();
  final _descC = TextEditingController();
  String _country = 'السعودية';
  String? _city;
  Map<String, List<String>> _places = {};
  String _cat = 'مواد بناء';
  DateTime? _deadline;
  bool _submitting = false;
  final _imagePicker = ImagePicker();
  List<XFile> _images = [];
  XFile? _video;

  @override
  void dispose() {
    _titleC.dispose();
    _qtyC.dispose();
    _budgetC.dispose();
    _descC.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _deadline = d);
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
      if (mounted) _showPickerError();
    }
  }

  Future<void> _pickVideo() async {
    try {
      final video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (!mounted || video == null) return;
      setState(() => _video = video);
    } on PlatformException {
      if (mounted) _showPickerError();
    }
  }

  void _showPickerError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تعذر اختيار الوسائط، يرجى المحاولة مرة أخرى'),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final imageBase64 = await Future.wait(
      _images.map((image) async => base64Encode(await image.readAsBytes())),
    );
    if (!mounted) return;
    Navigator.pop(
      context,
      PurchaseRequest(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleC.text.trim(),
        status: 'مفتوح',
        buyerName: widget.ownerName,
        contactPerson: widget.ownerName,
        quantity: _qtyC.text.trim(),
        budget: _budgetC.text.trim(),
        country: _country,
        city: _city ?? '',
        places: {
          _country: List.unmodifiable(_places[_country] ?? const <String>[]),
        },
        description: _descC.text.trim(),
        deadline: _deadline == null
            ? null
            : '${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}',
        category: _cat,
        ownerId: widget.ownerId,
        imageBase64: imageBase64,
      ),
    );
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
          'نشر طلب شراء',
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
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'انشر طلب الشراء ليراه الموردون والمصانع ويتقدموا بعروضهم.',
                        style: TextStyle(
                          color: fgColor,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _label('عنوان الطلب', fgColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleC,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: 'مثال: أجهزة تكييف سبليت 3 طن — 500 وحدة',
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
              _label('الكمية', fgColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyC,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(hintText: '500 وحدة'),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 20),
              _label('الدولة', fgColor),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: const ValueKey('request-country'),
                initialValue: _country,
                items: GulfLocations.countries
                    .map(
                      (country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      ),
                    )
                    .toList(),
                onChanged: (country) => setState(() {
                  _country = country!;
                  _city = null;
                  _places = {};
                }),
              ),
              const SizedBox(height: 20),
              _label('المدينة (اختياري)', fgColor),
              const SizedBox(height: 8),
              PlacesSelector(
                key: ValueKey('request-places-$_country'),
                countries: [_country],
                places: _places,
                onChanged: (places) => setState(() {
                  _places = places;
                  final cities = _places[_country] ?? const <String>[];
                  _city = cities.isEmpty ? null : cities.first;
                }),
              ),
              const SizedBox(height: 20),
              _label('الميزانية', fgColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetC,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: '400,000 - 600,000 ر.س',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'يرجى إدخال الميزانية' : null,
              ),
              const SizedBox(height: 20),
              _label('آخر موعد للعروض (اختياري)', fgColor),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPanel2 : AppColors.panel2,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: mutedColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _deadline != null
                            ? '${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}'
                            : 'اختر التاريخ',
                        style: TextStyle(
                          color: _deadline != null ? fgColor : mutedColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label('تفاصيل الطلب', fgColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descC,
                textDirection: TextDirection.rtl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'اكتب تفاصيل ما تحتاجه بدقة...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'يرجى إدخال التفاصيل' : null,
              ),
              const SizedBox(height: 20),
              _label('الصور والفيديو (اختياري)', fgColor),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('إضافة صور متعددة'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library_outlined),
                    label: const Text('إضافة فيديو'),
                  ),
                ],
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
                      _SelectedImage(
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
              if (_video != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPanel2 : AppColors.panel2,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.video_file_outlined,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _video!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(color: fgColor, fontSize: 13),
                        ),
                      ),
                      IconButton(
                        tooltip: 'إزالة الفيديو',
                        onPressed: () => setState(() => _video = null),
                        icon: const Icon(Icons.close),
                        color: mutedColor,
                      ),
                    ],
                  ),
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
                          'نشر الطلب',
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
}

class _SelectedImage extends StatefulWidget {
  const _SelectedImage({
    super.key,
    required this.image,
    required this.onRemove,
  });

  final XFile image;
  final VoidCallback onRemove;

  @override
  State<_SelectedImage> createState() => _SelectedImageState();
}

class _SelectedImageState extends State<_SelectedImage> {
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
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
