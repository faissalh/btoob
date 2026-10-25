import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/offer.dart';
import '../models/local_message.dart';
import '../models/purchase_request.dart';

class LocalMarketplaceStore {
  static const _offersKey = 'marketplace_user_offers';
  static const _requestsKey = 'marketplace_user_requests';
  static const _messagesKey = 'marketplace_user_messages';

  Future<List<Offer>> loadOffers() async {
    final preferences = await SharedPreferences.getInstance();
    final json = preferences.getString(_offersKey);
    if (json == null) return [];
    return (jsonDecode(json) as List)
        .map((item) => Offer.fromJson(Map<String, Object?>.from(item as Map)))
        .toList();
  }

  Future<List<PurchaseRequest>> loadRequests() async {
    final preferences = await SharedPreferences.getInstance();
    final json = preferences.getString(_requestsKey);
    if (json == null) return [];
    return (jsonDecode(json) as List)
        .map(
          (item) =>
              PurchaseRequest.fromJson(Map<String, Object?>.from(item as Map)),
        )
        .toList();
  }

  Future<List<LocalMessage>> loadMessages() async {
    final preferences = await SharedPreferences.getInstance();
    final json = preferences.getString(_messagesKey);
    if (json == null) return [];
    return (jsonDecode(json) as List)
        .map(
          (item) =>
              LocalMessage.fromJson(Map<String, Object?>.from(item as Map)),
        )
        .toList();
  }

  Future<void> saveOffers(List<Offer> offers) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _offersKey,
      jsonEncode(offers.map((offer) => offer.toJson()).toList()),
    );
    if (!saved) throw StateError('تعذر حفظ العروض على هذا الجهاز');
  }

  Future<void> saveRequests(List<PurchaseRequest> requests) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _requestsKey,
      jsonEncode(requests.map((request) => request.toJson()).toList()),
    );
    if (!saved) throw StateError('تعذر حفظ طلبات الشراء على هذا الجهاز');
  }

  Future<void> deleteOffer(String offerId) async {
    final offers = await loadOffers();
    final remainingOffers = offers
        .where((offer) => offer.id != offerId)
        .toList();
    if (remainingOffers.length == offers.length) {
      throw StateError('العرض غير موجود في التخزين المحلي');
    }
    await saveOffers(remainingOffers);
  }

  Future<void> deleteRequest(String requestId) async {
    final requests = await loadRequests();
    final remainingRequests = requests
        .where((request) => request.id != requestId)
        .toList();
    if (remainingRequests.length == requests.length) {
      throw StateError('الطلب غير موجود في التخزين المحلي');
    }
    await saveRequests(remainingRequests);
  }

  Future<void> saveMessages(List<LocalMessage> messages) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedMessages = jsonEncode(
      messages.map((message) => message.toJson()).toList(),
    );
    if (encodedMessages.length > 1500000) {
      throw StateError(
        'امتلأت مساحة الرسائل المحلية. احذف بعض المرفقات القديمة قبل الإرسال',
      );
    }
    final saved = await preferences.setString(_messagesKey, encodedMessages);
    if (!saved) throw StateError('تعذر حفظ الرسائل على هذا الجهاز');
  }

  Future<void> deleteUserData(String userId) async {
    final remainingOffers = (await loadOffers())
        .where((offer) => offer.ownerId != userId)
        .toList();
    final remainingRequests = (await loadRequests())
        .where((request) => request.ownerId != userId)
        .toList();
    final remainingMessages = (await loadMessages())
        .where((message) => message.ownerId != userId)
        .toList();

    await saveOffers(remainingOffers);
    await saveRequests(remainingRequests);
    await saveMessages(remainingMessages);
  }
}
