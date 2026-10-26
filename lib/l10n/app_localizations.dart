import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @productType.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productType;

  /// No description provided for @serviceType.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceType;

  /// No description provided for @savePost.
  ///
  /// In en, this message translates to:
  /// **'Save post'**
  String get savePost;

  /// No description provided for @removeSavedPost.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved posts'**
  String get removeSavedPost;

  /// No description provided for @deleteOffer.
  ///
  /// In en, this message translates to:
  /// **'Delete offer'**
  String get deleteOffer;

  /// No description provided for @deleteRequest.
  ///
  /// In en, this message translates to:
  /// **'Delete purchase request'**
  String get deleteRequest;

  /// No description provided for @verifiedPublisher.
  ///
  /// In en, this message translates to:
  /// **'Verified publisher'**
  String get verifiedPublisher;

  /// No description provided for @minimumOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum order: {value}'**
  String minimumOrder(String value);

  /// No description provided for @requestQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {value}'**
  String requestQuantity(String value);

  /// No description provided for @requestDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline: {value}'**
  String requestDeadline(String value);

  /// No description provided for @openRequest.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openRequest;

  /// No description provided for @closedRequest.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedRequest;

  /// No description provided for @ratingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get ratingUnavailable;

  /// No description provided for @offerDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer details'**
  String get offerDetailsTitle;

  /// No description provided for @requestDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase request details'**
  String get requestDetailsTitle;

  /// No description provided for @offerDescription.
  ///
  /// In en, this message translates to:
  /// **'Offer description'**
  String get offerDescription;

  /// No description provided for @requestDescription.
  ///
  /// In en, this message translates to:
  /// **'Request details'**
  String get requestDescription;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @budgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetLabel;

  /// No description provided for @minimumOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum order'**
  String get minimumOrderLabel;

  /// No description provided for @featuresLabel.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get featuresLabel;

  /// No description provided for @targetPlacesLabel.
  ///
  /// In en, this message translates to:
  /// **'Target countries and cities'**
  String get targetPlacesLabel;

  /// No description provided for @supplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplierLabel;

  /// No description provided for @buyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyerLabel;

  /// No description provided for @contactPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact person'**
  String get contactPersonLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @deadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadlineLabel;

  /// No description provided for @allCities.
  ///
  /// In en, this message translates to:
  /// **'All cities'**
  String get allCities;

  /// No description provided for @contactSupplier.
  ///
  /// In en, this message translates to:
  /// **'Contact supplier'**
  String get contactSupplier;

  /// No description provided for @requestQuote.
  ///
  /// In en, this message translates to:
  /// **'Request a quote'**
  String get requestQuote;

  /// No description provided for @makeOffer.
  ///
  /// In en, this message translates to:
  /// **'Submit your offer'**
  String get makeOffer;

  /// No description provided for @contactBuyer.
  ///
  /// In en, this message translates to:
  /// **'Contact buyer'**
  String get contactBuyer;

  /// No description provided for @sharePost.
  ///
  /// In en, this message translates to:
  /// **'Share post'**
  String get sharePost;

  /// No description provided for @shareOfferCopied.
  ///
  /// In en, this message translates to:
  /// **'Offer link copied'**
  String get shareOfferCopied;

  /// No description provided for @shareRequestCopied.
  ///
  /// In en, this message translates to:
  /// **'Request link copied'**
  String get shareRequestCopied;

  /// No description provided for @savedPostMessage.
  ///
  /// In en, this message translates to:
  /// **'Post saved'**
  String get savedPostMessage;

  /// No description provided for @removedSavedPostMessage.
  ///
  /// In en, this message translates to:
  /// **'Post removed from saved items'**
  String get removedSavedPostMessage;

  /// No description provided for @productDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productDetailsLabel;

  /// No description provided for @serviceDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceDetailsLabel;

  /// No description provided for @openRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openRequestStatus;

  /// No description provided for @closedRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedRequestStatus;

  /// No description provided for @citiesPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Cities in {country}'**
  String citiesPickerLabel(String country);

  /// No description provided for @optionalCitiesHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose specific cities or leave all cities selected'**
  String get optionalCitiesHelp;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @arabicLanguageName.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabicLanguageName;

  /// No description provided for @englishLanguageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguageName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
