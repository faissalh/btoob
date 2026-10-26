import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:b2b_souq/l10n/app_localizations.dart';
import 'package:b2b_souq/data/local_marketplace_store.dart';
import 'package:b2b_souq/data/local_user_store.dart';
import 'package:b2b_souq/widgets/account_avatar.dart';
import 'package:b2b_souq/widgets/offer_card.dart';
import 'package:b2b_souq/widgets/post_media_thumbnail.dart';
import 'package:b2b_souq/widgets/post_card.dart';
import 'package:b2b_souq/widgets/places_selector.dart';
import 'package:b2b_souq/widgets/request_card.dart';
import 'package:b2b_souq/main.dart' show MainShell, SouqApp;
import 'package:b2b_souq/models/local_message.dart';
import 'package:b2b_souq/screens/offers_screen.dart';
import 'package:b2b_souq/screens/auth_screen.dart';
import 'package:b2b_souq/screens/company_detail_screen.dart';
import 'package:b2b_souq/screens/post_offer_screen.dart';
import 'package:b2b_souq/screens/post_request_screen.dart';
import 'package:b2b_souq/screens/private_chat_screen.dart';
import 'package:b2b_souq/screens/post_detail_screen.dart';
import 'package:b2b_souq/screens/requests_screen.dart';
import 'package:b2b_souq/screens/suppliers_screen.dart';
import 'package:b2b_souq/models/purchase_request.dart';
import 'package:b2b_souq/models/offer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Post places round-trip and legacy records remain readable', () {
    final offer = Offer.fromJson({
      'id': 'places-offer',
      'title': 'عرض',
      'type': 'منتج',
      'price': '10',
      'category': 'أخرى',
      'countries': ['السعودية'],
      'companyName': 'شركة',
      'rating': 4.5,
      'places': {
        'السعودية': ['الرياض', 'جدة'],
      },
    });
    expect(offer.places['السعودية'], ['الرياض', 'جدة']);
    expect(Offer.fromJson({...offer.toJson()}).places, offer.places);

    final legacyRequest = PurchaseRequest.fromJson({
      'id': 'old-request',
      'title': 'طلب قديم',
      'status': 'مفتوح',
      'buyerName': 'مشتري',
      'contactPerson': 'مسؤول',
      'quantity': '10',
      'budget': '100',
      'country': 'السعودية',
      'city': 'الرياض',
    });
    expect(legacyRequest.places, isEmpty);
    expect(legacyRequest.location, 'السعودية · الرياض');
  });

  testWidgets('Account avatars distinguish supplier and buyer roles', (
    WidgetTester tester,
  ) async {
    const supplierKey = ValueKey('supplier-avatar-test');
    const buyerKey = ValueKey('buyer-avatar-test');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AccountAvatar(
                key: supplierKey,
                name: 'مصنع الخليج',
                role: 'مصنع',
              ),
              AccountAvatar(key: buyerKey, name: 'مشتري تجريبي', role: 'مشتري'),
            ],
          ),
        ),
      ),
    );

    final supplierContainer = tester.widget<Container>(
      find.descendant(
        of: find.byKey(supplierKey),
        matching: find.byType(Container),
      ),
    );
    final buyerContainer = tester.widget<Container>(
      find.descendant(
        of: find.byKey(buyerKey),
        matching: find.byType(Container),
      ),
    );
    expect(
      (supplierContainer.decoration! as BoxDecoration).border!.top.width,
      3,
    );
    expect(
      (buyerContainer.decoration! as BoxDecoration).border!.top.width,
      1.2,
    );
    final supplierInitials = tester.widget<Text>(
      find.descendant(of: find.byKey(supplierKey), matching: find.byType(Text)),
    );
    final buyerInitials = tester.widget<Text>(
      find.descendant(of: find.byKey(buyerKey), matching: find.byType(Text)),
    );
    expect(supplierInitials.data, isNotEmpty);
    expect(buyerInitials.data, isNotEmpty);
  });

  testWidgets('Post media thumbnail shows first image and localized count', (
    WidgetTester tester,
  ) async {
    const image =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/pWQAAAAASUVORK5CYII=';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const Directionality(
            textDirection: TextDirection.rtl,
            child: PostMediaThumbnail(images: [image, image, image, image]),
          ),
        ),
      ),
    );
    expect(find.text('1/4'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('1/4')).textDirection,
      TextDirection.ltr,
    );
    expect(find.byType(Image), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Icon && widget.icon == Icons.broken_image_outlined,
      ),
      findsNothing,
    );
  });

  testWidgets('Invalid post image displays fallback icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PostMediaThumbnail(images: ['invalid-base64'])),
      ),
    );
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });

  testWidgets('Places can be selected per country or left as all cities', (
    WidgetTester tester,
  ) async {
    var places = <String, List<String>>{};
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SingleChildScrollView(
              child: PlacesSelector(
                countries: const ['السعودية'],
                places: places,
                onChanged: (value) => setState(() => places = value),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('place-city-السعودية-الرياض')));
    await tester.pumpAndSettle();
    expect(places['السعودية'], ['الرياض']);
    await tester.tap(find.byKey(const ValueKey('all-cities-السعودية')));
    await tester.pumpAndSettle();
    expect(places['السعودية'], isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Single-image details show a counter without thumbnails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PostDetailScreen(
          id: 'single-image',
          isOffer: true,
          isService: false,
          title: 'Single image',
          category: 'General',
          publisherName: 'Supplier',
          images: postImageProviders(['invalid image']),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('1/1'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('post-detail-thumbnail-single-image-0')),
      findsNothing,
    );
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile language setting changes the app direction and locale', (
    WidgetTester tester,
  ) async {
    var locale = const Locale('ar');
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainShell(
            isDark: false,
            onDarkToggle: (_) {},
            onLocaleChanged: (value) => setState(() => locale = value),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسابي').last);
    await tester.pumpAndSettle();
    final languageTile = find.text('اللغة');
    await tester.ensureVisible(languageTile);
    await tester.tap(languageTile);
    await tester.pumpAndSettle();
    await tester.tap(find.text('الإنجليزية').last);
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(locale, const Locale('en'));
    expect(
      Directionality.of(tester.element(find.byType(MainShell))),
      TextDirection.ltr,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Post detail supports image carousel and all offer actions', (
    WidgetTester tester,
  ) async {
    const image =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/pWQAAAAASUVORK5CYII=';
    var contactCount = 0;
    var saveCount = 0;
    var shareCount = 0;
    var publisherCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PostDetailScreen(
          id: 'detail-offer',
          isOffer: true,
          isService: true,
          title: 'خدمة صيانة',
          category: 'خدمات',
          description: 'صيانة دورية للمعدات',
          value: '100 ريال',
          minimumOrder: '3 وحدات',
          countries: const ['السعودية', 'الإمارات'],
          places: const {
            'السعودية': ['الرياض'],
            'الإمارات': [],
          },
          publisherName: 'مورد موثق',
          publisherRole: 'مورد',
          isVerified: true,
          rating: 4.8,
          images: postImageProviders([image, image, image]),
          isSaved: true,
          onToggleSaved: () => saveCount++,
          onShare: () => shareCount++,
          onContact: () => contactCount++,
          onSecondaryAction: () => contactCount++,
          onPublisherTap: () => publisherCount++,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('كل المدن'), findsOneWidget);
    expect(find.byIcon(Icons.verified), findsOneWidget);
    final thirdThumbnail = find.byKey(
      const ValueKey('post-detail-thumbnail-detail-offer-2'),
    );
    expect(thirdThumbnail, findsOneWidget);
    await tester.ensureVisible(thirdThumbnail);
    await tester.tap(thirdThumbnail);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.text('3/3'), findsOneWidget);

    final shareButton = find.byTooltip('مشاركة المنشور');
    await tester.ensureVisible(shareButton);
    await tester.tap(shareButton);
    await tester.pump();
    expect(shareCount, 1);
    final savedButton = find.byTooltip('إزالة من المحفوظات');
    await tester.ensureVisible(savedButton);
    await tester.tap(savedButton);
    await tester.pump();
    expect(saveCount, 1);
    final publisherCard = find.byKey(
      const ValueKey('post-detail-publisher-detail-offer'),
    );
    await tester.ensureVisible(publisherCard);
    await tester.tap(publisherCard);
    await tester.pump();
    expect(publisherCount, 1);
    final contactButton = find.byKey(const ValueKey('post-detail-contact'));
    expect(contactButton, findsOneWidget);
    await tester.tap(contactButton);
    await tester.pump();
    await tester.tap(find.text('طلب عرض سعر'));
    await tester.pump();
    expect(contactCount, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Request detail without images localizes and keeps actions', (
    WidgetTester tester,
  ) async {
    var actions = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PostDetailScreen(
          id: 'detail-request',
          isOffer: false,
          isService: false,
          title: 'Need equipment',
          category: 'Equipment',
          value: 'Up to 1000',
          countries: const ['السعودية'],
          places: const {'السعودية': []},
          publisherName: 'Purchaser',
          publisherRole: 'buyer',
          requestStatus: 'مفتوح',
          contactPerson: 'Purchasing manager',
          quantity: '10 units',
          onContact: () => actions++,
          onSecondaryAction: () => actions++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('post-detail-gallery-detail-request')),
      findsNothing,
    );
    expect(find.text('All cities'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Contact buyer'), findsOneWidget);
    expect(find.text('Submit your offer'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(PostDetailScreen))),
      TextDirection.ltr,
    );
    await tester.tap(find.text('Contact buyer'));
    await tester.pump();
    await tester.tap(find.text('Submit your offer'));
    await tester.pump();
    expect(actions, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Offer without images remains compact and shows publisher data', (
    WidgetTester tester,
  ) async {
    const offer = Offer(
      id: 'compact-offer',
      title: 'عرض بلا صور',
      type: 'خدمة',
      price: 'حسب الطلب',
      minOrder: '5 وحدات',
      category: 'خدمات',
      countries: ['السعودية'],
      companyName: 'شركة موثقة',
      isVerified: true,
      rating: 4.8,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: SizedBox(width: 200, child: OfferCard(offer: offer)),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(PostMediaThumbnail), findsNothing);
    expect(find.byTooltip('خدمة'), findsOneWidget);
    expect(find.byIcon(Icons.verified), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(tester.getSize(find.byType(PostCard)).height, lessThan(280));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Offer and request cards preview images in both directions', (
    WidgetTester tester,
  ) async {
    const image =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/pWQAAAAASUVORK5CYII=';
    const offer = Offer(
      id: 'preview-offer',
      title: 'عرض مع صورة',
      type: 'منتج',
      price: '10',
      category: 'أخرى',
      countries: ['السعودية'],
      companyName: 'شركة تجريبية',
      rating: 0,
      imageBase64: [image, image],
    );
    const request = PurchaseRequest(
      id: 'preview-request',
      title: 'طلب مع صورة',
      status: 'مفتوح',
      buyerName: 'مشتري تجريبي',
      contactPerson: 'مسؤول المشتريات',
      quantity: '10',
      budget: '100',
      country: 'السعودية',
      city: 'الرياض',
      imageBase64: [image, image],
    );

    Future<void> pumpDirection(TextDirection direction) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: direction,
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 180,
                      child: OfferCard(
                        offer: offer,
                        isFavorite: true,
                        onFavoriteToggle: () {},
                      ),
                    ),
                    const SizedBox(
                      width: 360,
                      child: RequestCard(request: request),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    await pumpDirection(TextDirection.rtl);
    const offerMediaKey = ValueKey('post-media-offer-preview-offer');
    const requestMediaKey = ValueKey('post-media-request-preview-request');
    expect(find.byKey(offerMediaKey), findsOneWidget);
    expect(find.byKey(requestMediaKey), findsOneWidget);
    expect(find.text('1/2'), findsNWidgets(2));
    final rtlImage = tester.getTopLeft(find.byKey(offerMediaKey));
    final rtlImageSize = tester.getSize(find.byKey(offerMediaKey));
    final rtlBadge = tester.getCenter(
      find.descendant(
        of: find.byKey(offerMediaKey),
        matching: find.byKey(const ValueKey('post-media-count-badge')),
      ),
    );
    final rtlTypeIcon = tester.getCenter(find.byTooltip('منتج'));
    final rtlBookmark = tester.getCenter(find.byIcon(Icons.bookmark));
    expect(rtlImageSize.width / rtlImageSize.height, closeTo(4 / 3, 0.02));
    expect(rtlBadge.dx, lessThan(rtlImage.dx + rtlImageSize.width / 2));
    expect(rtlTypeIcon.dx, greaterThan(rtlImage.dx + rtlImageSize.width / 2));
    expect(rtlBookmark.dx, lessThan(rtlImage.dx + rtlImageSize.width / 2));
    expect(tester.takeException(), isNull);

    await pumpDirection(TextDirection.ltr);
    final ltrImage = tester.getTopLeft(find.byKey(offerMediaKey));
    final ltrImageSize = tester.getSize(find.byKey(offerMediaKey));
    final ltrBadge = tester.getCenter(
      find.descendant(
        of: find.byKey(offerMediaKey),
        matching: find.byKey(const ValueKey('post-media-count-badge')),
      ),
    );
    final ltrTypeIcon = tester.getCenter(find.byTooltip('Product'));
    final ltrBookmark = tester.getCenter(find.byIcon(Icons.bookmark));
    expect(ltrBadge.dx, greaterThan(ltrImage.dx + ltrImageSize.width / 2));
    expect(ltrTypeIcon.dx, lessThan(ltrImage.dx + ltrImageSize.width / 2));
    expect(ltrBookmark.dx, greaterThan(ltrImage.dx + ltrImageSize.width / 2));
    await tester.drag(find.byKey(offerMediaKey), const Offset(-150, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('2/2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile avatars appear on owned offers and purchase requests', (
    WidgetTester tester,
  ) async {
    const avatar =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/pWQAAAAASUVORK5CYII=';
    final userStore = LocalUserStore();
    final profile = await userStore.createAccount(
      fullName: 'مورد الاختبار',
      username: 'avatar_supplier',
      password: 'pass1234',
      phone: '',
      email: 'avatar@example.com',
      country: 'السعودية',
      city: 'الرياض',
      website: 'example.com',
      role: 'مورد',
    );
    final updatedProfile = profile.copyWith(avatarBase64: avatar);
    await userStore.saveProfile(updatedProfile);
    final store = LocalMarketplaceStore();
    await store.saveOffers([
      Offer(
        id: 'avatar-offer',
        title: 'عرض بصورة الحساب',
        type: 'منتج',
        price: '100 ريال',
        category: 'أخرى',
        countries: const ['السعودية'],
        companyName: updatedProfile.fullName,
        rating: 0,
        ownerId: updatedProfile.id,
      ),
    ]);
    await store.saveRequests([
      PurchaseRequest(
        id: 'avatar-request',
        title: 'طلب بصورة الحساب',
        status: 'مفتوح',
        buyerName: updatedProfile.fullName,
        contactPerson: updatedProfile.fullName,
        quantity: '10',
        budget: '1000 ريال',
        country: 'السعودية',
        city: 'الرياض',
        ownerId: updatedProfile.id,
      ),
    ]);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('العروض').last);
    await tester.pumpAndSettle();

    final offerAvatarFinder = find.byKey(
      const ValueKey('offer-avatar-avatar-offer'),
    );
    expect(offerAvatarFinder, findsOneWidget);
    expect(
      tester.widget<AccountAvatar>(offerAvatarFinder).avatarBase64,
      avatar,
    );
    await tester.tap(find.text('عرض بصورة الحساب'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AccountAvatar>(
            find.byKey(const ValueKey('offer-detail-avatar')),
          )
          .avatarBase64,
      avatar,
    );

    await tester.tap(find.byKey(const ValueKey('post-detail-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الطلبات').last);
    await tester.pumpAndSettle();
    final requestAvatarFinder = find.byKey(
      const ValueKey('request-avatar-avatar-request'),
    );
    expect(requestAvatarFinder, findsOneWidget);
    expect(
      tester.widget<AccountAvatar>(requestAvatarFinder).avatarBase64,
      avatar,
    );
    await tester.tap(find.text('طلب بصورة الحساب'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AccountAvatar>(
            find.byKey(const ValueKey('request-detail-avatar')),
          )
          .avatarBase64,
      avatar,
    );
  });

  testWidgets('Demo account logs in with the displayed credentials', (
    WidgetTester tester,
  ) async {
    var authenticated = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Column(
              children: [
                Text(authenticated ? 'authenticated' : 'guest'),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute<bool>(
                        builder: (_) => const AuthScreen(),
                      ),
                    );
                    if (result == true) {
                      setState(() => authenticated = true);
                    }
                  },
                  child: const Text('فتح الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('فتح الدخول'));
    await tester.pumpAndSettle();

    expect(find.text('اسم المستخدم: demo'), findsOneWidget);
    expect(find.text('كلمة المرور: demo123'), findsOneWidget);
    await tester.tap(find.text('استخدام بيانات الحساب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دخول').last);
    await tester.pumpAndSettle();

    expect(find.text('authenticated'), findsOneWidget);
  });

  testWidgets('Invalid demo login stays on the sign-in screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AuthScreen())),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('auth-username')),
      'wrong',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-password')),
      'wrong',
    );
    await tester.tap(find.text('دخول').last);
    await tester.pumpAndSettle();

    expect(
      find.text('بيانات الدخول غير صحيحة، تحقق من اسم المستخدم وكلمة المرور'),
      findsOneWidget,
    );
    expect(find.byType(AuthScreen), findsOneWidget);
  });

  testWidgets('Account creation form is reachable from sign-in screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AuthScreen())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('حساب جديد'));
    await tester.pumpAndSettle();

    expect(find.text('إنشاء حساب'), findsWidgets);
    expect(find.byKey(const ValueKey('auth-email')), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-website')), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-country')), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-city-السعودية')), findsOneWidget);
  });

  testWidgets('New account can be created without a website and sign in', (
    WidgetTester tester,
  ) async {
    var authenticated = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(builder: (_) => const AuthScreen()),
                );
                if (result == true) setState(() => authenticated = true);
              },
              child: Text(authenticated ? 'تم الدخول' : 'فتح الحساب'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('فتح الحساب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حساب جديد'));
    await tester.pumpAndSettle();
    final nameField = find.byKey(const ValueKey('auth-name'));
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'مها سالم');
    final usernameField = find.byKey(const ValueKey('auth-username'));
    await tester.ensureVisible(usernameField);
    await tester.enterText(usernameField, 'maha_test');
    final passwordField = find.byKey(const ValueKey('auth-password'));
    await tester.ensureVisible(passwordField);
    await tester.enterText(passwordField, 'pass1234');
    final emailField = find.byKey(const ValueKey('auth-email'));
    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'maha@example.com');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final createButton = find.byType(ElevatedButton).last;
    await tester.scrollUntilVisible(
      createButton,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('تم الدخول'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    final createdId = preferences.getString('active_user_id');
    expect(createdId, isNotNull);
    await preferences.remove('active_user_id');
    await preferences.setBool('demo_account_logged_in', false);
    await tester.tap(find.text('تم الدخول'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('auth-username')),
      'maha_test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-password')),
      'pass1234',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final loginButton = find.byType(ElevatedButton).last;
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(preferences.getString('active_user_id'), createdId);
  });

  testWidgets('Logged-in account remains visible after switching tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('حسابي').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('حساب جديد'), findsOneWidget);
    await tester.tap(find.text('استخدام بيانات الحساب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دخول').last);
    await tester.pumpAndSettle();

    expect(find.text('أحمد محمد'), findsOneWidget);
    await tester.tap(find.text('العروض').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();

    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('زائر'), findsNothing);
  });

  testWidgets('Profile details can be edited and persist on this device', (
    WidgetTester tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('demo_account_logged_in', true);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('demo@souq.local'), findsOneWidget);

    final editButton = find.byKey(const ValueKey('edit-profile'));
    await tester.ensureVisible(editButton);
    await tester.tap(editButton);
    await tester.pumpAndSettle();
    expect(find.text('تعديل الملف الشخصي'), findsOneWidget);
    final bioField = find.byKey(const ValueKey('profile-bio'));
    await tester.ensureVisible(bioField);
    await tester.pumpAndSettle();
    await tester.enterText(bioField, 'مشتري مهتم بالمواد الصناعية');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final saveButton = find.text('حفظ التعديلات');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ التعديلات'));
    await tester.pumpAndSettle();

    expect(find.text('مشتري مهتم بالمواد الصناعية'), findsOneWidget);
    expect(find.text('demo@souq.local'), findsOneWidget);
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسابي').last);
    await tester.pumpAndSettle();
    expect(find.text('مشتري مهتم بالمواد الصناعية'), findsOneWidget);
  });

  testWidgets(
    'Personal offers and requests can be deleted individually from account',
    (WidgetTester tester) async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('demo_account_logged_in', true);
      final store = LocalMarketplaceStore();
      await store.saveOffers([
        const Offer(
          id: 'my-offer',
          title: 'عرضي للحذف',
          type: 'منتج',
          price: '100 ريال',
          category: 'أخرى',
          countries: ['السعودية'],
          companyName: 'أحمد محمد',
          rating: 0,
          ownerId: 'demo',
        ),
        const Offer(
          id: 'other-offer',
          title: 'عرض مستخدم آخر',
          type: 'منتج',
          price: '200 ريال',
          category: 'أخرى',
          countries: ['السعودية'],
          companyName: 'مستخدم آخر',
          rating: 0,
          ownerId: 'other-user',
        ),
      ]);
      await store.saveRequests([
        const PurchaseRequest(
          id: 'my-request',
          title: 'طلبي للحذف',
          status: 'مفتوح',
          buyerName: 'أحمد محمد',
          contactPerson: 'أحمد محمد',
          quantity: '10',
          budget: '1000 ريال',
          country: 'السعودية',
          city: 'الرياض',
          ownerId: 'demo',
        ),
        const PurchaseRequest(
          id: 'other-request',
          title: 'طلب مستخدم آخر',
          status: 'مفتوح',
          buyerName: 'مستخدم آخر',
          contactPerson: 'مستخدم آخر',
          quantity: '20',
          budget: '2000 ريال',
          country: 'السعودية',
          city: 'جدة',
          ownerId: 'other-user',
        ),
      ]);
      await store.saveMessages([
        LocalMessage(
          id: 'existing-message',
          ownerId: 'demo',
          recipientName: 'مورد',
          subject: 'استفسار',
          body: 'تبقى الرسالة كما هي',
          sentAt: DateTime.utc(2026),
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('حسابي'));
      await tester.pumpAndSettle();
      final myOffersTile = find.text('عروضي');
      await tester.ensureVisible(myOffersTile);
      await tester.tap(myOffersTile);
      await tester.pumpAndSettle();

      final offerDeleteButton = find.byKey(
        const ValueKey('delete-offer-my-offer'),
      );
      await tester.ensureVisible(offerDeleteButton);
      await tester.tap(offerDeleteButton);
      await tester.pumpAndSettle();
      expect(find.text('حذف العرض؟'), findsOneWidget);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect((await store.loadOffers()).map((offer) => offer.id), [
        'my-offer',
        'other-offer',
      ]);

      await tester.tap(offerDeleteButton);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('confirm-delete-offer-my-offer')),
      );
      await tester.pumpAndSettle();
      expect(find.text('عرضي للحذف'), findsNothing);
      expect((await store.loadOffers()).map((offer) => offer.id), [
        'other-offer',
      ]);

      await tester.tap(find.text('حسابي').last);
      await tester.pumpAndSettle();
      final myRequestsTile = find.text('1 طلب');
      await tester.ensureVisible(myRequestsTile);
      await tester.tap(myRequestsTile);
      await tester.pumpAndSettle();
      final requestDeleteButton = find.byKey(
        const ValueKey('delete-request-my-request'),
      );
      await tester.ensureVisible(requestDeleteButton);
      await tester.tap(requestDeleteButton);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('confirm-delete-request-my-request')),
      );
      await tester.pumpAndSettle();
      expect(find.text('طلبي للحذف'), findsNothing);
      expect((await store.loadRequests()).map((request) => request.id), [
        'other-request',
      ]);
      expect((await store.loadMessages()).single.id, 'existing-message');
    },
  );

  testWidgets(
    'Deleting account removes its content and preserves other users',
    (WidgetTester tester) async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('demo_account_logged_in', true);
      final marketplaceStore = LocalMarketplaceStore();
      await marketplaceStore.saveOffers([
        const Offer(
          id: 'demo-offer',
          title: 'عرض الحساب',
          type: 'product',
          price: '10',
          category: 'أخرى',
          countries: ['السعودية'],
          companyName: 'أحمد محمد',
          rating: 0,
          ownerId: 'demo',
        ),
        const Offer(
          id: 'other-offer',
          title: 'عرض مستخدم آخر',
          type: 'product',
          price: '20',
          category: 'أخرى',
          countries: ['السعودية'],
          companyName: 'مستخدم آخر',
          rating: 0,
          ownerId: 'other-user',
        ),
      ]);
      await marketplaceStore.saveRequests([
        const PurchaseRequest(
          id: 'demo-request',
          title: 'طلب الحساب',
          status: 'نشط',
          buyerName: 'أحمد محمد',
          contactPerson: 'أحمد محمد',
          quantity: '1',
          budget: '10',
          country: 'السعودية',
          city: 'الرياض',
          ownerId: 'demo',
        ),
        const PurchaseRequest(
          id: 'other-request',
          title: 'طلب مستخدم آخر',
          status: 'نشط',
          buyerName: 'مستخدم آخر',
          contactPerson: 'مستخدم آخر',
          quantity: '1',
          budget: '20',
          country: 'السعودية',
          city: 'جدة',
          ownerId: 'other-user',
        ),
      ]);
      await marketplaceStore.saveMessages([
        LocalMessage(
          id: 'demo-message',
          ownerId: 'demo',
          recipientName: 'مورد',
          subject: 'استفسار',
          body: 'رسالة الحساب',
          sentAt: DateTime.utc(2026),
        ),
        LocalMessage(
          id: 'other-message',
          ownerId: 'other-user',
          recipientName: 'مورد آخر',
          subject: 'استفسار',
          body: 'رسالة مستخدم آخر',
          sentAt: DateTime.utc(2026),
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('حسابي'));
      await tester.pumpAndSettle();
      final deleteButton = find.byKey(const ValueKey('delete-account'));
      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      expect(find.text('حذف الحساب؟'), findsOneWidget);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(preferences.getBool('demo_account_logged_in'), isTrue);

      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-delete-account')));
      await tester.pumpAndSettle();
      expect(preferences.getBool('demo_account_logged_in'), isFalse);
      expect(preferences.getString('active_user_id'), isNull);
      expect(await LocalUserStore().login('demo', 'demo123'), isFalse);

      expect((await marketplaceStore.loadOffers()).map((offer) => offer.id), [
        'other-offer',
      ]);
      expect(
        (await marketplaceStore.loadRequests()).map((request) => request.id),
        ['other-request'],
      );
      expect(
        (await marketplaceStore.loadMessages()).map((message) => message.id),
        ['other-message'],
      );
    },
  );

  test(
    'Deleting a registered account preserves other local accounts',
    () async {
      final userStore = LocalUserStore();
      final firstAccount = await userStore.createAccount(
        fullName: 'مستخدم أول',
        username: 'first_user',
        password: 'pass1234',
        phone: '',
        email: 'first@example.com',
        country: 'السعودية',
        city: 'الرياض',
        website: 'example.com',
        role: 'buyer',
      );
      final secondAccount = await userStore.createAccount(
        fullName: 'مستخدم ثان',
        username: 'second_user',
        password: 'pass1234',
        phone: '',
        email: 'second@example.com',
        country: 'السعودية',
        city: 'جدة',
        website: 'example.com',
        role: 'buyer',
      );
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('active_user_id', firstAccount.id);

      await userStore.deleteAccount(firstAccount.id);

      expect(await userStore.loadProfile(firstAccount.id), isNull);
      expect(await userStore.loadProfile(secondAccount.id), isNotNull);
      expect(preferences.getString('active_user_id'), isNull);
      expect(preferences.getBool('demo_account_logged_in'), isFalse);
    },
  );

  testWidgets('Demo account remains logged in after app shell is recreated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('استخدام بيانات الحساب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دخول').last);
    await tester.pumpAndSettle();
    expect(find.text('أحمد محمد'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();

    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('زائر'), findsNothing);
  });

  testWidgets('App launches and main sections render', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SouqApp());
    expect(find.text('سوق'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    for (final tab in ['العروض', 'الطلبات', 'الموردون', 'الرئيسية', 'حسابي']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.text('الوضع الداكن'), findsOneWidget);
  });

  testWidgets('Supplier city filter supports selecting multiple cities', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SuppliersScreen())),
    );

    expect(find.text('6 شركة'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('supplier-city-filter')));
    await tester.pumpAndSettle();
    await _selectLocationOption(tester, 'country-السعودية');
    await _selectLocationOption(tester, 'city-الرياض');
    await _selectLocationOption(tester, 'city-جدة');
    await tester.tap(find.text('تطبيق'));
    await tester.pumpAndSettle();

    expect(find.text('2 شركة'), findsOneWidget);
    expect(find.text('مصنع الخليج للبلاستيك'), findsOneWidget);
    expect(find.text('تقنية الشرق الحديثة'), findsOneWidget);
    expect(find.text('الشرق المتوسط للصلب'), findsNothing);
  });

  testWidgets('Supplier city filter can be reset to all cities', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SuppliersScreen())),
    );

    await tester.tap(find.byKey(const ValueKey('supplier-city-filter')));
    await tester.pumpAndSettle();
    await _selectLocationOption(tester, 'city-الرياض');
    await tester.tap(find.text('تطبيق'));
    await tester.pumpAndSettle();
    expect(find.text('1 شركة'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('supplier-city-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('location-all')));
    await tester.tap(find.text('تطبيق'));
    await tester.pumpAndSettle();

    expect(find.text('6 شركة'), findsOneWidget);
  });

  testWidgets('Supplier list filters by selected country', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SuppliersScreen())),
    );

    await tester.tap(find.byKey(const ValueKey('supplier-city-filter')));
    await tester.pumpAndSettle();
    await _selectLocationOption(tester, 'country-الكويت');
    await tester.tap(find.text('تطبيق'));
    await tester.pumpAndSettle();

    expect(find.text('1 شركة'), findsOneWidget);
    expect(find.text('المصنع الوطني للأغذية'), findsOneWidget);
    expect(find.text('مصنع الخليج للبلاستيك'), findsNothing);
  });

  testWidgets('Suppliers can be filtered by their offer categories', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SuppliersScreen())),
    );

    await tester.tap(find.byKey(const ValueKey('supplier-category-filter')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('مواد غذائية'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('مواد غذائية').last);
    await tester.pumpAndSettle();

    expect(find.text('1 شركة'), findsOneWidget);
    expect(find.text('المصنع الوطني للأغذية'), findsOneWidget);
    expect(find.text('تقنية الشرق الحديثة'), findsNothing);
  });

  testWidgets('Offers filter by supplier country and city', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OffersScreen())),
    );

    await tester.tap(find.byKey(const ValueKey('offers-location-filter')));
    await tester.pumpAndSettle();
    await _selectLocationOption(tester, 'country-السعودية');
    await _selectLocationOption(tester, 'city-الرياض');
    await tester.tap(find.text('تطبيق'));
    await tester.pumpAndSettle();

    expect(find.text('1 عرض'), findsOneWidget);
    expect(find.text('أنابيب PP-R للسباكة — أقطار متعددة'), findsOneWidget);
  });

  testWidgets('Purchase requests filter by country and city', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RequestsScreen())),
    );

    await tester.tap(find.byKey(const ValueKey('requests-location-filter')));
    await tester.pumpAndSettle();
    await _selectLocationOption(tester, 'country-السعودية');
    await _selectLocationOption(tester, 'city-الرياض');
    await tester.tap(find.text('تطبيق'));
    await tester.pumpAndSettle();

    expect(find.text('1 طلب'), findsOneWidget);
    expect(find.text('طابعات حرارية للمطاعم — 200 وحدة'), findsOneWidget);
  });

  testWidgets('Purchase requests can be filtered by category', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RequestsScreen())),
    );

    await tester.tap(find.byKey(const ValueKey('requests-category-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أجهزة كهربائية').last);
    await tester.pumpAndSettle();

    expect(find.text('1 طلب'), findsOneWidget);
    expect(find.text('أجهزة تكييف سبليت 3 طن — 500 وحدة'), findsOneWidget);
    expect(find.text('طابعات حرارية للمطاعم — 200 وحدة'), findsNothing);
  });

  testWidgets('Other category includes requests with unlisted categories', (
    WidgetTester tester,
  ) async {
    const otherRequest = PurchaseRequest(
      id: 'other-request',
      title: 'طلب لفئة غير مدرجة',
      status: 'مفتوح',
      buyerName: 'شركة الاختبار',
      contactPerson: 'مسؤول المشتريات',
      quantity: '10 وحدات',
      budget: '1000 ريال',
      country: 'السعودية',
      city: 'الرياض',
      category: 'معدات بحرية',
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RequestsScreen(requests: [otherRequest])),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('requests-category-filter')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('أخرى'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('أخرى').last);
    await tester.pumpAndSettle();

    expect(find.text('1 طلب'), findsOneWidget);
    expect(find.text('طلب لفئة غير مدرجة'), findsOneWidget);
  });

  testWidgets('Purchase request city choices follow the selected country', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PostRequestScreen()));

    await tester.tap(find.byKey(const ValueKey('request-country')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الإمارات').last);
    await tester.pumpAndSettle();

    final cityOptions = find.byKey(const ValueKey('request-places-الإمارات'));
    await tester.ensureVisible(cityOptions);
    await tester.tap(cityOptions);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('place-city-الإمارات-أبوظبي')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('place-city-الإمارات-دبي')),
      findsOneWidget,
    );
    expect(find.text('الرياض'), findsNothing);
  });

  testWidgets('Offer locations allow multiple cities within a country', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PostOfferScreen()));

    expect(find.text('إضافة صور متعددة'), findsOneWidget);
    final locationButton = find.byKey(const ValueKey('post-offer-location'));
    await tester.ensureVisible(locationButton);
    await tester.pumpAndSettle();
    await tester.tap(locationButton);
    await tester.pumpAndSettle();
    await _selectLocationOption(tester, 'country-الإمارات');
    await _selectLocationOption(tester, 'city-أبوظبي');
    await _selectLocationOption(tester, 'city-دبي');
    await tester.tap(find.text('تطبيق'));
    await tester.pumpAndSettle();

    expect(find.text('الإمارات · 2 مدن'), findsOneWidget);
  });

  testWidgets('Publishing a request requires login first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: MainShell(isDark: false, onDarkToggle: (_) {})),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('نشر عرض'), findsNothing);
    final searchOrRequestButton = find.text('ابحث أو اطلب');
    await tester.ensureVisible(searchOrRequestButton);
    await tester.tap(searchOrRequestButton);
    await tester.pumpAndSettle();

    expect(find.text('طلب شراء'), findsAtLeastNWidgets(1));
    expect(find.text('نشر عرض أو منتج'), findsOneWidget);
    await tester.tap(find.text('طلب شراء').last);
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    await tester.tap(find.text('استخدام بيانات الحساب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دخول').last);
    await tester.pumpAndSettle();

    expect(find.text('نشر طلب شراء'), findsOneWidget);
  });

  testWidgets('Published offer is saved and shown in its owner profile', (
    WidgetTester tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('demo_account_logged_in', true);
    await tester.pumpWidget(
      MaterialApp(home: MainShell(isDark: false, onDarkToggle: (_) {})),
    );
    await tester.pumpAndSettle();

    final searchOrRequestButton = find.text('ابحث أو اطلب');
    await tester.ensureVisible(searchOrRequestButton);
    await tester.tap(searchOrRequestButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('نشر عرض أو منتج'));
    await tester.pumpAndSettle();

    expect(find.text('نشر عرض جديد'), findsOneWidget);
    final offerFields = find.byType(TextFormField);
    await tester.enterText(offerFields.at(0), 'عرض تجريبي للاختبار');
    await tester.enterText(offerFields.at(1), '10 ر.س');
    await tester.enterText(offerFields.at(3), 'تفاصيل العرض التجريبي');

    final locationButton = find.byKey(const ValueKey('post-offer-location'));
    await tester.ensureVisible(locationButton);
    await tester.pumpAndSettle();
    await tester.tap(locationButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('country-السعودية')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تطبيق'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('نشر العرض'));
    await tester.tap(find.text('نشر العرض'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();

    expect(find.text('1 عرض'), findsOneWidget);
    final myOffers = find.text('عروضي');
    await tester.ensureVisible(myOffers);
    await tester.pumpAndSettle();
    await tester.tap(myOffers);
    await tester.pumpAndSettle();
    expect(find.text('عرض تجريبي للاختبار'), findsOneWidget);
  });

  testWidgets('Published request is saved and shown in its owner profile', (
    WidgetTester tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('demo_account_logged_in', true);
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
      ),
    );
    await tester.pumpAndSettle();

    final cta = find.text('ابحث أو اطلب');
    await tester.ensureVisible(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();
    await tester.tap(find.text('طلب شراء').last);
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'طلب تجريبي للاختبار');
    await tester.enterText(fields.at(1), '25 وحدة');
    await tester.enterText(fields.at(2), '5000 ريال');
    await tester.enterText(fields.at(3), 'تفاصيل الطلب التجريبي');
    final cityPicker = find.byKey(const ValueKey('place-city-السعودية-الرياض'));
    await tester.ensureVisible(cityPicker);
    await tester.pumpAndSettle();
    await tester.tap(cityPicker);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('نشر الطلب'));
    await tester.tap(find.text('نشر الطلب'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    expect(find.text('1 طلب'), findsOneWidget);
    final myRequests = find.text('طلبات الشراء');
    await tester.ensureVisible(myRequests);
    await tester.pumpAndSettle();
    await tester.tap(myRequests);
    await tester.pumpAndSettle();
    expect(find.text('طلب تجريبي للاختبار'), findsOneWidget);
  });

  testWidgets('Contact messages are saved in the signed-in user inbox', (
    WidgetTester tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('demo_account_logged_in', true);
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('العروض').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('رمل وحصى مكسر — توريد يومي'));
    await tester.pumpAndSettle();
    expect(find.byType(PostDetailScreen), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('post-detail-contact')));
    await tester.pumpAndSettle();
    expect(find.text('الرمال والحصى للإعمار'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-attach')), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-record')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('chat-composer')),
      'أرغب بمعرفة السعر',
    );
    await tester.tap(find.byKey(const ValueKey('chat-send')));
    await tester.pumpAndSettle();
    expect(find.text('أرغب بمعرفة السعر'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('post-detail-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    expect(find.text('1 رسالة'), findsOneWidget);
    final inboxTile = find.text('الرسائل');
    await tester.ensureVisible(inboxTile);
    await tester.pumpAndSettle();
    await tester.tap(inboxTile);
    await tester.pumpAndSettle();
    expect(find.textContaining('أرغب بمعرفة السعر'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('conversation-avatar-demo::الرمال والحصى للإعمار'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('conversation-demo::الرمال والحصى للإعمار')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PrivateChatScreen), findsOneWidget);
    expect(find.text('أرغب بمعرفة السعر'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-recipient-avatar')), findsOneWidget);
    expect(find.byType(AccountAvatar), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('chat-recipient-profile')));
    await tester.pumpAndSettle();
    expect(find.byType(CompanyDetailScreen), findsOneWidget);
    expect(find.text('عن الشركة'), findsOneWidget);
  });

  testWidgets(
    'Deleting a conversation is confirmed and only removes local chat',
    (WidgetTester tester) async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('demo_account_logged_in', true);
      final store = LocalMarketplaceStore();
      await store.saveMessages([
        LocalMessage(
          id: 'conversation-one',
          ownerId: 'demo',
          recipientName: 'الرمال والحصى للإعمار',
          subject: 'استفسار',
          body: 'محادثة أولى',
          sentAt: DateTime.utc(2026, 10, 20),
        ),
        LocalMessage(
          id: 'conversation-two',
          ownerId: 'demo',
          recipientName: 'الشرق المتوسط للصلب',
          subject: 'استفسار',
          body: 'محادثة ثانية',
          sentAt: DateTime.utc(2026, 10, 21),
        ),
        LocalMessage(
          id: 'other-account-message',
          ownerId: 'other-user',
          recipientName: 'جهة أخرى',
          subject: 'استفسار',
          body: 'رسالة حساب مختلف',
          sentAt: DateTime.utc(2026, 10, 22),
        ),
      ]);
      await tester.pumpWidget(
        const MaterialApp(
          home: MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('حسابي'));
      await tester.pumpAndSettle();
      final inbox = find.text('الرسائل');
      await tester.ensureVisible(inbox);
      await tester.tap(inbox);
      await tester.pumpAndSettle();

      final firstThread = find.byKey(
        const ValueKey('conversation-demo::الرمال والحصى للإعمار'),
      );
      final secondThread = find.byKey(
        const ValueKey('conversation-demo::الشرق المتوسط للصلب'),
      );
      await tester.longPress(firstThread);
      await tester.pumpAndSettle();
      await tester.tap(secondThread);
      await tester.pumpAndSettle();
      expect(find.text('تم تحديد 2 محادثة'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('delete-selected-conversations')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('حذف 2 محادثات عندي'));
      await tester.pumpAndSettle();
      expect(find.text('تأكيد حذف المحادثة'), findsOneWidget);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect((await store.loadMessages()).length, 3);

      await tester.tap(
        find.byKey(const ValueKey('delete-selected-conversations')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('حذف 2 محادثات عندي'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('confirm-delete-conversations')),
      );
      await tester.pumpAndSettle();

      final remaining = await store.loadMessages();
      expect(remaining.map((message) => message.id), ['other-account-message']);
      expect(
        find.byKey(const ValueKey('conversation-demo::الرمال والحصى للإعمار')),
        findsNothing,
      );
    },
  );

  testWidgets('Deleting a chat message locally can be undone', (
    WidgetTester tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('demo_account_logged_in', true);
    final store = LocalMarketplaceStore();
    await store.saveMessages([
      LocalMessage(
        id: 'undo-message',
        ownerId: 'demo',
        recipientName: 'الرمال والحصى للإعمار',
        subject: 'استفسار',
        body: 'رسالة قابلة للتراجع',
        sentAt: DateTime.utc(2026, 10, 22),
      ),
    ]);
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(isDark: false, onDarkToggle: _ignoreDarkMode),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    final inbox = find.text('الرسائل');
    await tester.ensureVisible(inbox);
    await tester.tap(inbox);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('conversation-demo::الرمال والحصى للإعمار')),
    );
    await tester.pumpAndSettle();

    final messageBody = find.text('رسالة قابلة للتراجع');
    await tester.ensureVisible(messageBody);
    await tester.longPress(messageBody);
    await tester.pumpAndSettle();
    expect(find.text('تم تحديد 1 رسائل'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('delete-selected-messages')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف الرسالة عندي'));
    await tester.pumpAndSettle();
    expect(await store.loadMessages(), isEmpty);
    expect(find.text('رسالة قابلة للتراجع'), findsNothing);

    await tester.tap(find.text('تراجع'));
    await tester.pumpAndSettle();
    expect((await store.loadMessages()).single.id, 'undo-message');
    expect(find.text('رسالة قابلة للتراجع'), findsOneWidget);
  });

  test('Chat media metadata and audio payload survive local storage', () async {
    final audioMessage = LocalMessage(
      id: 'voice-1',
      ownerId: 'demo',
      recipientName: 'مورد تجريبي',
      subject: 'محادثة خاصة',
      body: '',
      sentAt: DateTime.utc(2026, 10, 21),
      type: 'audio',
      attachmentName: 'رسالة صوتية',
      attachmentMimeType: 'audio/webm',
      attachmentBase64: 'dGVzdA==',
    );
    final store = LocalMarketplaceStore();
    await store.saveMessages([audioMessage]);

    final restored = await store.loadMessages();
    expect(restored, hasLength(1));
    expect(restored.single.type, 'audio');
    expect(restored.single.attachmentMimeType, 'audio/webm');
    expect(restored.single.attachmentBase64, 'dGVzdA==');
    expect(restored.single.threadId, 'demo::مورد تجريبي');
  });
}

void _ignoreDarkMode(bool _) {}

Future<void> _selectLocationOption(WidgetTester tester, String key) async {
  final option = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(
    option,
    240,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
}
