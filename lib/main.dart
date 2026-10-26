import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/app_localizations.dart';
import 'l10n/post_card_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/offers_screen.dart';
import 'screens/requests_screen.dart';
import 'screens/suppliers_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/post_offer_screen.dart';
import 'screens/post_request_screen.dart';
import 'data/local_marketplace_store.dart';
import 'data/local_user_store.dart';
import 'data/supabase_config.dart';
import 'data/supabase_marketplace_store.dart';
import 'data/supabase_user_store.dart';
import 'data/mock_data.dart';
import 'models/offer.dart';
import 'models/purchase_request.dart';
import 'models/local_message.dart';
import 'models/company.dart';
import 'models/user_profile.dart';
import 'screens/messages_screen.dart';
import 'screens/private_chat_screen.dart';
import 'screens/company_detail_screen.dart';
import 'widgets/account_avatar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseConfig.initialize();
    runApp(const SouqApp());
  } on Object catch (error) {
    runApp(SupabaseStartupFailure(error: error));
  }
}

class SupabaseStartupFailure extends StatelessWidget {
  final Object error;

  const SupabaseStartupFailure({super.key, required this.error});

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SelectableText(
            'تعذر الاتصال بخدمة Supabase عند بدء التطبيق.\n\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}

class SouqApp extends StatefulWidget {
  const SouqApp({super.key});
  @override
  State<SouqApp> createState() => _SouqAppState();
}

class _SouqAppState extends State<SouqApp> {
  bool _isDark = false;
  bool _showSplash = true;
  Locale _locale = const Locale('ar');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق | B2B',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routes: const {},
      home: _showSplash
          ? SplashScreen(onComplete: () => setState(() => _showSplash = false))
          : MainShell(
              isDark: _isDark,
              onDarkToggle: (v) => setState(() => _isDark = v),
              onLocaleChanged: (locale) => setState(() => _locale = locale),
            ),
    );
  }
}

class MainShell extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onDarkToggle;
  final ValueChanged<Locale>? onLocaleChanged;
  const MainShell({
    super.key,
    required this.isDark,
    required this.onDarkToggle,
    this.onLocaleChanged,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final LocalMarketplaceStore _marketplaceStore = SupabaseConfig.isInitialized
      ? SupabaseMarketplaceStore()
      : LocalMarketplaceStore();
  final LocalUserStore _userStore = SupabaseConfig.isInitialized
      ? SupabaseUserStore()
      : LocalUserStore();

  int _tab = 0;
  bool _isLoggedIn = false;
  bool _isLoadingData = true;
  String? _loadError;
  UserProfile? _currentUser;
  Map<String, UserProfile> _profilesById = {};
  bool _showMyOffers = false;
  bool _showMyRequests = false;
  List<Offer> _offers = List.of(MockData.offers);
  List<PurchaseRequest> _requests = List.of(MockData.purchaseRequests);
  List<LocalMessage> _messages = [];
  final Set<String> _favorites = {};
  RealtimeChannel? _messageChannel;

  @override
  void initState() {
    super.initState();
    _restoreLogin();
    _restoreMarketplaceData();
  }

  @override
  void dispose() {
    final channel = _messageChannel;
    if (channel != null && SupabaseConfig.isInitialized) {
      SupabaseConfig.client.removeChannel(channel);
    }
    super.dispose();
  }

  void _watchMessages() {
    final oldChannel = _messageChannel;
    if (oldChannel != null && SupabaseConfig.isInitialized) {
      SupabaseConfig.client.removeChannel(oldChannel);
      _messageChannel = null;
    }
    final store = _marketplaceStore;
    if (store is! SupabaseMarketplaceStore ||
        SupabaseConfig.client.auth.currentUser == null) {
      return;
    }
    _messageChannel = store.watchMessages(_refreshMessages);
  }

  Future<void> _refreshMessages() async {
    final messages = await _marketplaceStore.loadMessages();
    if (mounted) setState(() => _messages = messages);
  }

  Future<void> _restoreLogin() async {
    try {
      final user = await _userStore.restoreSession();
      final profiles = await _userStore.loadProfiles();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _profilesById = {for (final profile in profiles) profile.id: profile};
          if (user != null) _profilesById[user.id] = user;
          _isLoggedIn = user != null;
        });
        _watchMessages();
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _loadError = 'تعذر استعادة الحساب من Supabase: $error';
        });
      }
    }
  }

  Future<void> _restoreMarketplaceData() async {
    try {
      final savedOffers = await _marketplaceStore.loadOffers();
      final savedRequests = await _marketplaceStore.loadRequests();
      final savedMessages = await _marketplaceStore.loadMessages();
      final profiles = await _userStore.loadProfiles();
      if (!mounted) return;
      setState(() {
        _offers = [...savedOffers, ...MockData.offers];
        _requests = [...savedRequests, ...MockData.purchaseRequests];
        _messages = savedMessages;
        _profilesById = {
          ..._profilesById,
          for (final profile in profiles) profile.id: profile,
        };
        _isLoadingData = false;
        _loadError = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingData = false;
        _loadError = SupabaseConfig.isInitialized
            ? 'تعذر تحميل البيانات من Supabase. تأكد من تشغيل supabase/schema.sql '
                  'في SQL Editor ثم أعد المحاولة.\n$error'
            : 'تعذر تحميل البيانات المحلية: $error';
      });
    }
  }

  Future<void> _login() async {
    final user = await _userStore.restoreSession();
    final profiles = await _userStore.loadProfiles();
    if (mounted) {
      if (user == null) {
        throw StateError('تعذر استعادة الحساب بعد تسجيل الدخول');
      }
      setState(() {
        _currentUser = user;
        _profilesById = {for (final profile in profiles) profile.id: profile};
        _profilesById[user.id] = user;
        _isLoggedIn = true;
      });
      _watchMessages();
    }
  }

  Future<void> _logout() async {
    await _userStore.logout();
    final channel = _messageChannel;
    _messageChannel = null;
    if (channel != null && SupabaseConfig.isInitialized) {
      await SupabaseConfig.client.removeChannel(channel);
    }
    if (mounted) {
      setState(() {
        _currentUser = null;
        _isLoggedIn = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    final userId = _userId;
    await _marketplaceStore.deleteUserData(userId);
    await _userStore.deleteAccount(userId);
    final channel = _messageChannel;
    _messageChannel = null;
    if (channel != null && SupabaseConfig.isInitialized) {
      await SupabaseConfig.client.removeChannel(channel);
    }
    final remainingOffers = await _marketplaceStore.loadOffers();
    final remainingRequests = await _marketplaceStore.loadRequests();
    final remainingMessages = await _marketplaceStore.loadMessages();
    if (!mounted) return;
    setState(() {
      _offers = [...remainingOffers, ...MockData.offers];
      _requests = [...remainingRequests, ...MockData.purchaseRequests];
      _messages = remainingMessages;
      _currentUser = null;
      _profilesById.remove(userId);
      _isLoggedIn = false;
      _showMyOffers = false;
      _showMyRequests = false;
      _tab = 4;
    });
  }

  Future<void> _saveProfile(UserProfile profile) async {
    await _userStore.saveProfile(profile);
    if (mounted) {
      setState(() {
        _currentUser = profile;
        _profilesById[profile.id] = profile;
      });
    }
  }

  String get _userId => _currentUser?.id ?? 'demo';

  UserProfile? _profileFor(String? userId, String name) {
    return resolveAccountProfile(_profilesById, userId: userId, name: name);
  }

  Future<bool> _requireLogin() async {
    if (_isLoggedIn) return true;
    final authenticated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const AuthScreen()),
    );
    if (!mounted || authenticated != true) return false;
    await _login();
    return true;
  }

  Future<void> _startPostOffer() async {
    if (!await _requireLogin() || !mounted) return;
    final offer = await Navigator.push<Offer>(
      context,
      MaterialPageRoute(
        builder: (_) => PostOfferScreen(
          ownerId: _userId,
          ownerName: _currentUser!.fullName,
        ),
      ),
    );
    if (offer == null) return;
    final userOffers = [
      offer,
      ..._offers.where((item) => item.ownerId == _userId),
    ];
    await _marketplaceStore.saveOffers(userOffers);
    if (!mounted) return;
    setState(() {
      _offers = [offer, ..._offers];
      _showMyOffers = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نشر العرض وحفظه في حسابك')),
    );
  }

  Future<List<LocalMessage>> _deleteMessages(List<String> messageIds) async {
    final ids = messageIds.toSet();
    final deleted = _messages
        .where(
          (message) => message.ownerId == _userId && ids.contains(message.id),
        )
        .toList();
    if (deleted.isEmpty) return [];
    if (_marketplaceStore case final SupabaseMarketplaceStore store) {
      await store.hideMessages(deleted.map((message) => message.id).toList());
    }
    final deletedIds = deleted.map((message) => message.id).toSet();
    final remainingMessages = _messages
        .where((message) => !deletedIds.contains(message.id))
        .toList();
    if (_marketplaceStore is! SupabaseMarketplaceStore) {
      await _marketplaceStore.saveMessages(remainingMessages);
    }
    if (mounted) setState(() => _messages = remainingMessages);
    return deleted;
  }

  Future<void> _restoreMessages(List<LocalMessage> messages) async {
    final existingIds = _messages.map((message) => message.id).toSet();
    final restored = [
      ...messages.where((message) => !existingIds.contains(message.id)),
      ..._messages,
    ]..sort((first, second) => second.sentAt.compareTo(first.sentAt));
    if (_marketplaceStore case final SupabaseMarketplaceStore store) {
      await store.restoreMessages(
        messages.map((message) => message.id).toList(),
      );
    } else {
      await _marketplaceStore.saveMessages(restored);
    }
    if (mounted) setState(() => _messages = restored);
  }

  Future<void> _deleteConversations(List<String> recipientNames) async {
    final recipients = recipientNames.toSet();
    if (_marketplaceStore case final SupabaseMarketplaceStore store) {
      for (final recipient in recipients) {
        await store.hideConversation(recipient);
      }
      await _refreshMessages();
      return;
    }
    final remainingMessages = _messages
        .where(
          (message) =>
              message.ownerId != _userId ||
              !recipients.contains(message.recipientName),
        )
        .toList();
    await _marketplaceStore.saveMessages(remainingMessages);
    if (mounted) setState(() => _messages = remainingMessages);
  }

  Future<void> _startPostRequest() async {
    if (!await _requireLogin() || !mounted) return;
    final request = await Navigator.push<PurchaseRequest>(
      context,
      MaterialPageRoute(
        builder: (_) => PostRequestScreen(
          ownerId: _userId,
          ownerName: _currentUser!.fullName,
        ),
      ),
    );
    if (request == null) return;
    final userRequests = [
      request,
      ..._requests.where((item) => item.ownerId == _userId),
    ];
    await _marketplaceStore.saveRequests(userRequests);
    if (!mounted) return;
    setState(() {
      _requests = [request, ..._requests];
      _showMyRequests = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نشر الطلب وحفظه في حسابك')),
    );
  }

  Future<void> _deleteOffer(String offerId) async {
    final userId = _userId;
    if (!_isLoggedIn ||
        !_offers.any(
          (offer) => offer.id == offerId && offer.ownerId == userId,
        )) {
      throw StateError('لا يمكنك حذف عرض لا تملكه');
    }
    await _marketplaceStore.deleteOffer(offerId);
    if (!mounted) return;
    setState(() => _offers.removeWhere((offer) => offer.id == offerId));
  }

  Future<void> _deleteRequest(String requestId) async {
    final userId = _userId;
    if (!_isLoggedIn ||
        !_requests.any(
          (request) => request.id == requestId && request.ownerId == userId,
        )) {
      throw StateError('لا يمكنك حذف طلب لا تملكه');
    }
    await _marketplaceStore.deleteRequest(requestId);
    if (!mounted) return;
    setState(() => _requests.removeWhere((request) => request.id == requestId));
  }

  Future<void> _sendMessage(String recipientName) async {
    if (!await _requireLogin() || !mounted) return;
    final recipientProfile = _profileFor(null, recipientName);
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PrivateChatScreen(
          ownerId: _userId,
          recipientName: recipientName,
          recipientId: recipientProfile?.id,
          messages: _messages
              .where(
                (message) =>
                    message.ownerId == _userId &&
                    message.recipientName == recipientName,
              )
              .toList(),
          ownerProfile: _currentUser,
          recipientProfile: recipientProfile,
          onSend: _saveChatMessage,
          onDeleteMessages: _deleteMessages,
          onRestoreMessages: _restoreMessages,
          onOpenRecipientProfile: () => _openRecipientProfile(recipientName),
        ),
      ),
    );
  }

  void _openRecipientProfile(String recipientName) {
    Company? company;
    for (final item in MockData.companies) {
      if (item.name == recipientName) {
        company = item;
        break;
      }
    }
    if (company == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ملف الشركة غير متاح')));
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyDetailScreen(
          company: company!,
          onContact: _sendMessage,
          avatarBase64: _profileFor(null, company.name)?.avatarBase64,
        ),
      ),
    );
  }

  Future<void> _saveChatMessage(LocalMessage message) async {
    final updatedMessages = [message, ..._messages];
    if (_marketplaceStore is SupabaseMarketplaceStore) {
      await _marketplaceStore.saveMessages([message]);
    } else {
      await _marketplaceStore.saveMessages(updatedMessages);
    }
    if (!mounted) return;
    setState(() => _messages = updatedMessages);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          SupabaseConfig.isInitialized
              ? 'تم إرسال الرسالة وحفظها'
              : 'تم إرسال الرسالة وحفظها محلياً',
        ),
      ),
    );
  }

  Future<void> _viewMessages() async {
    if (!await _requireLogin() || !mounted) return;
    setState(() => _tab = 5);
  }

  void _openConversation(String recipientName) {
    _sendMessage(recipientName);
  }

  void _toggleFavorite(String id) {
    final localizations = postCardLocalizations(context);
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.removedSavedPostMessage)),
        );
      } else {
        _favorites.add(id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.savedPostMessage)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(
        offers: _offers,
        requests: _requests,
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
        onNavigateToOffers: () => setState(() => _tab = 1),
        onNavigateToRequests: () => setState(() => _tab = 2),
        onNavigateToSuppliers: () => setState(() => _tab = 3),
        onPostOffer: _startPostOffer,
        onPostRequest: _startPostRequest,
        onContact: _sendMessage,
        profilesById: _profilesById,
      ),
      OffersScreen(
        offers: _offers,
        userId: _showMyOffers ? _userId : null,
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
        onContact: _sendMessage,
        onDeleteOffer: _showMyOffers ? _deleteOffer : null,
        profilesById: _profilesById,
      ),
      RequestsScreen(
        requests: _requests,
        userId: _showMyRequests ? _userId : null,
        onContact: _sendMessage,
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
        onDeleteRequest: _showMyRequests ? _deleteRequest : null,
        profilesById: _profilesById,
      ),
      SuppliersScreen(
        onContact: _sendMessage,
        profilesById: _profilesById,
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
      ),
      ProfileScreen(
        isDarkMode: widget.isDark,
        onDarkModeToggle: widget.onDarkToggle,
        locale: Localizations.localeOf(context),
        onLocaleChanged: widget.onLocaleChanged,
        isLoggedIn: _isLoggedIn,
        userProfile: _currentUser,
        onLogin: _login,
        onLogout: _logout,
        onDeleteAccount: _deleteAccount,
        onSaveProfile: _saveProfile,
        offerCount: _offers.where((offer) => offer.ownerId == _userId).length,
        requestCount: _requests
            .where((request) => request.ownerId == _userId)
            .length,
        onViewOffers: () => setState(() {
          _showMyOffers = true;
          _tab = 1;
        }),
        onViewRequests: () => setState(() {
          _showMyRequests = true;
          _tab = 2;
        }),
        messageCount: _messages
            .where((message) => message.ownerId == _userId)
            .length,
        onViewMessages: _viewMessages,
      ),
      MessagesScreen(
        messages: _messages
            .where((message) => message.ownerId == _userId)
            .toList(),
        onOpenConversation: _openConversation,
        onDeleteConversations: _deleteConversations,
        profilesById: _profilesById,
      ),
    ];

    const titles = [
      'سوق',
      'العروض والمنتجات',
      'طلبات الشراء',
      'الموردون والمصانع',
      'حسابي',
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: _tab == 5,
        leading: _tab == 5
            ? IconButton(
                tooltip: 'العودة إلى الحساب',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _tab = 4),
              )
            : null,
        title: Text(
          _tab == 5 ? 'الرسائل' : titles[_tab],
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_loadError != null)
                  MaterialBanner(
                    content: SelectableText(_loadError!),
                    leading: const Icon(Icons.cloud_off_outlined),
                    actions: [
                      TextButton(
                        onPressed: _restoreMarketplaceData,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: screens[_tab],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkLine : AppColors.line,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab == 5 ? 4 : _tab,
          onTap: (i) => setState(() => _tab = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              activeIcon: Icon(Icons.local_offer),
              label: 'العروض',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'الطلبات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              activeIcon: Icon(Icons.business),
              label: 'الموردون',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}
