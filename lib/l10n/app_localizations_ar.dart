// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get productType => 'منتج';

  @override
  String get serviceType => 'خدمة';

  @override
  String get savePost => 'حفظ المنشور';

  @override
  String get removeSavedPost => 'إزالة من المحفوظات';

  @override
  String get deleteOffer => 'حذف العرض';

  @override
  String get deleteRequest => 'حذف طلب الشراء';

  @override
  String get verifiedPublisher => 'ناشر موثّق';

  @override
  String minimumOrder(String value) {
    return 'الحد الأدنى: $value';
  }

  @override
  String requestQuantity(String value) {
    return 'الكمية: $value';
  }

  @override
  String requestDeadline(String value) {
    return 'آخر موعد: $value';
  }

  @override
  String get openRequest => 'مفتوح';

  @override
  String get closedRequest => 'مغلق';

  @override
  String get ratingUnavailable => '—';

  @override
  String get offerDetailsTitle => 'تفاصيل العرض';

  @override
  String get requestDetailsTitle => 'تفاصيل طلب الشراء';

  @override
  String get offerDescription => 'وصف العرض';

  @override
  String get requestDescription => 'تفاصيل الطلب';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get priceLabel => 'السعر';

  @override
  String get budgetLabel => 'الميزانية';

  @override
  String get minimumOrderLabel => 'الحد الأدنى';

  @override
  String get featuresLabel => 'المميزات';

  @override
  String get targetPlacesLabel => 'الدول والمدن المستهدفة';

  @override
  String get supplierLabel => 'المورد';

  @override
  String get buyerLabel => 'المشتري';

  @override
  String get contactPersonLabel => 'المسؤول';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get locationLabel => 'الموقع';

  @override
  String get deadlineLabel => 'آخر موعد';

  @override
  String get allCities => 'كل المدن';

  @override
  String get contactSupplier => 'تواصل مع المورد';

  @override
  String get requestQuote => 'طلب عرض سعر';

  @override
  String get makeOffer => 'قدّم عرضك';

  @override
  String get contactBuyer => 'تواصل مع المشتري';

  @override
  String get sharePost => 'مشاركة المنشور';

  @override
  String get shareOfferCopied => 'تم نسخ رابط العرض';

  @override
  String get shareRequestCopied => 'تم نسخ رابط الطلب';

  @override
  String get savedPostMessage => 'تم حفظ المنشور';

  @override
  String get removedSavedPostMessage => 'تمت إزالة المنشور من المحفوظات';

  @override
  String get productDetailsLabel => 'منتج';

  @override
  String get serviceDetailsLabel => 'خدمة';

  @override
  String get openRequestStatus => 'مفتوح';

  @override
  String get closedRequestStatus => 'مغلق';

  @override
  String citiesPickerLabel(String country) {
    return 'مدن $country';
  }

  @override
  String get optionalCitiesHelp =>
      'اختر مدناً محددة أو اترك الخيار ليشمل كل المدن';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get arabicLanguageName => 'العربية';

  @override
  String get englishLanguageName => 'الإنجليزية';
}
