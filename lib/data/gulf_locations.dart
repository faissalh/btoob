class GulfLocations {
  static const Map<String, List<String>> citiesByCountry = {
    'السعودية': [
      'الرياض',
      'جدة',
      'مكة المكرمة',
      'المدينة المنورة',
      'الدمام',
      'الخبر',
      'الطائف',
      'تبوك',
      'أبها',
      'بريدة',
      'حائل',
      'جازان',
      'نجران',
      'ينبع',
      'الأحساء',
      'عرعر',
      'سكاكا',
      'الباحة',
    ],
    'الإمارات': [
      'أبوظبي',
      'دبي',
      'الشارقة',
      'عجمان',
      'رأس الخيمة',
      'الفجيرة',
      'أم القيوين',
    ],
    'الكويت': ['الكويت', 'الأحمدي', 'حولي', 'الجهراء'],
    'قطر': ['الدوحة', 'الريان', 'الوكرة', 'الخور'],
    'البحرين': ['المنامة', 'المحرق', 'الرفاع', 'مدينة عيسى'],
    'عُمان': ['مسقط', 'صلالة', 'صحار', 'نزوى'],
  };

  static List<String> get countries => citiesByCountry.keys.toList();

  static List<String> citiesFor(Iterable<String> countries) => [
    for (final country in countries) ...?citiesByCountry[country],
  ];
}
