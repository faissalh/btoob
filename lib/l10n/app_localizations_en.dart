// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get productType => 'Product';

  @override
  String get serviceType => 'Service';

  @override
  String get savePost => 'Save post';

  @override
  String get removeSavedPost => 'Remove from saved posts';

  @override
  String get deleteOffer => 'Delete offer';

  @override
  String get deleteRequest => 'Delete purchase request';

  @override
  String get verifiedPublisher => 'Verified publisher';

  @override
  String minimumOrder(String value) {
    return 'Minimum order: $value';
  }

  @override
  String requestQuantity(String value) {
    return 'Quantity: $value';
  }

  @override
  String requestDeadline(String value) {
    return 'Deadline: $value';
  }

  @override
  String get openRequest => 'Open';

  @override
  String get closedRequest => 'Closed';

  @override
  String get ratingUnavailable => '—';

  @override
  String get offerDetailsTitle => 'Offer details';

  @override
  String get requestDetailsTitle => 'Purchase request details';

  @override
  String get offerDescription => 'Offer description';

  @override
  String get requestDescription => 'Request details';

  @override
  String get categoryLabel => 'Category';

  @override
  String get priceLabel => 'Price';

  @override
  String get budgetLabel => 'Budget';

  @override
  String get minimumOrderLabel => 'Minimum order';

  @override
  String get featuresLabel => 'Features';

  @override
  String get targetPlacesLabel => 'Target countries and cities';

  @override
  String get supplierLabel => 'Supplier';

  @override
  String get buyerLabel => 'Buyer';

  @override
  String get contactPersonLabel => 'Contact person';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get locationLabel => 'Location';

  @override
  String get deadlineLabel => 'Deadline';

  @override
  String get allCities => 'All cities';

  @override
  String get contactSupplier => 'Contact supplier';

  @override
  String get requestQuote => 'Request a quote';

  @override
  String get makeOffer => 'Submit your offer';

  @override
  String get contactBuyer => 'Contact buyer';

  @override
  String get sharePost => 'Share post';

  @override
  String get shareOfferCopied => 'Offer link copied';

  @override
  String get shareRequestCopied => 'Request link copied';

  @override
  String get savedPostMessage => 'Post saved';

  @override
  String get removedSavedPostMessage => 'Post removed from saved items';

  @override
  String get productDetailsLabel => 'Product';

  @override
  String get serviceDetailsLabel => 'Service';

  @override
  String get openRequestStatus => 'Open';

  @override
  String get closedRequestStatus => 'Closed';

  @override
  String citiesPickerLabel(String country) {
    return 'Cities in $country';
  }

  @override
  String get optionalCitiesHelp =>
      'Choose specific cities or leave all cities selected';

  @override
  String get languageLabel => 'Language';

  @override
  String get arabicLanguageName => 'العربية';

  @override
  String get englishLanguageName => 'English';
}
