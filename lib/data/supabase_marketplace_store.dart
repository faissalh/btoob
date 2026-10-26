import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/local_message.dart';
import '../models/offer.dart';
import '../models/purchase_request.dart';
import 'local_marketplace_store.dart';
import 'supabase_config.dart';

Map<String, List<String>> _placesFromRow(Object? value) {
  if (value is! Map) return const {};
  return {
    for (final entry in value.entries)
      if (entry.key is String && entry.value is List)
        entry.key as String: (entry.value as List).whereType<String>().toList(),
  };
}

class SupabaseMarketplaceStore extends LocalMarketplaceStore {
  SupabaseClient get _client => SupabaseConfig.client;
  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('يجب تسجيل الدخول لتنفيذ هذا الإجراء');
    return id;
  }

  @override
  Future<List<Offer>> loadOffers() async {
    final rows = await _client
        .from('offers')
        .select()
        .order('created_at', ascending: false);
    return rows.map((row) {
      final paths = (row['media_paths'] as List?)?.cast<String>() ?? const [];
      return Offer(
        id: row['id'] as String,
        title: row['title'] as String,
        type: row['type'] as String,
        price: row['price'] as String,
        minOrder: row['min_order'] as String?,
        category: row['category'] as String,
        countries: (row['countries'] as List).cast<String>(),
        places: _placesFromRow(row['places']),
        companyName: row['company_name'] as String,
        rating: 0,
        description: row['description'] as String?,
        details: row['details'] as String?,
        features: (row['features'] as List?)?.cast<String>() ?? const [],
        ownerId: row['owner_id'] as String,
        imageBase64: paths
            .map(
              (path) =>
                  _client.storage.from('listing-media').getPublicUrl(path),
            )
            .toList(),
      );
    }).toList();
  }

  @override
  Future<List<PurchaseRequest>> loadRequests() async {
    final rows = await _client
        .from('purchase_requests')
        .select()
        .order('created_at', ascending: false);
    return rows.map((row) {
      final paths = (row['media_paths'] as List?)?.cast<String>() ?? const [];
      return PurchaseRequest(
        id: row['id'] as String,
        title: row['title'] as String,
        status: row['status'] as String,
        buyerName: row['buyer_name'] as String,
        contactPerson: row['contact_person'] as String,
        quantity: row['quantity'] as String,
        budget: row['budget'] as String,
        country: row['country'] as String,
        city: row['city'] as String,
        places: _placesFromRow(row['places']),
        description: row['description'] as String?,
        deadline: row['deadline'] as String?,
        category: row['category'] as String?,
        ownerId: row['owner_id'] as String,
        imageBase64: paths
            .map(
              (path) =>
                  _client.storage.from('listing-media').getPublicUrl(path),
            )
            .toList(),
      );
    }).toList();
  }

  @override
  Future<List<LocalMessage>> loadMessages() async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return [];
    final rows = await _client
        .from('messages')
        .select('*, chats!inner(participant_one, participant_two)')
        .order('sent_at');
    final visibleRows = rows.where((row) {
      final deletedBy =
          (row['deleted_by'] as List?)?.cast<String>() ?? const [];
      return !deletedBy.contains(currentUserId);
    }).toList();
    final profiles = await _client.from('profiles').select('id, full_name');
    final namesById = {
      for (final row in profiles)
        row['id'] as String: row['full_name'] as String,
    };

    return Future.wait(
      visibleRows.map((row) async {
        final chat = row['chats'] as Map<String, dynamic>;
        final participantOne = chat['participant_one'] as String;
        final participantTwo = chat['participant_two'] as String;
        final recipientId = participantOne == currentUserId
            ? participantTwo
            : participantOne;
        final attachmentPath = row['attachment_path'] as String?;
        final signedAttachment = attachmentPath == null
            ? null
            : await _client.storage
                  .from('chat-media')
                  .createSignedUrl(attachmentPath, 86400);
        final sentAt = DateTime.parse(row['sent_at'] as String).toLocal();
        return LocalMessage(
          id: row['id'] as String,
          ownerId: currentUserId,
          senderId: row['sender_id'] as String,
          recipientId: recipientId,
          chatId: row['chat_id'] as String,
          recipientName: namesById[recipientId] ?? 'مستخدم',
          subject: 'محادثة خاصة',
          body: row['body'] as String,
          sentAt: sentAt,
          type: row['message_type'] as String,
          attachmentName: row['attachment_name'] as String?,
          attachmentMimeType: row['attachment_mime_type'] as String?,
          attachmentBase64: signedAttachment,
        );
      }),
    );
  }

  @override
  Future<void> saveOffers(List<Offer> offers) async {
    final rows = <Map<String, Object?>>[];
    for (final offer in offers) {
      final paths = await _uploadListingMedia(
        ownerId: _userId,
        listingId: offer.id,
        encodedMedia: offer.imageBase64,
      );
      rows.add({
        'id': offer.id,
        'owner_id': _userId,
        'title': offer.title,
        'type': offer.type,
        'price': offer.price,
        'min_order': offer.minOrder,
        'category': offer.category,
        'countries': offer.countries,
        'places': offer.places,
        'company_name': offer.companyName,
        'description': offer.description,
        'details': offer.details,
        'features': offer.features,
        'media_paths': paths,
      });
    }
    if (rows.isNotEmpty) await _client.from('offers').upsert(rows);
  }

  @override
  Future<void> saveRequests(List<PurchaseRequest> requests) async {
    final rows = <Map<String, Object?>>[];
    for (final request in requests) {
      final paths = await _uploadListingMedia(
        ownerId: _userId,
        listingId: request.id,
        encodedMedia: request.imageBase64,
      );
      rows.add({
        'id': request.id,
        'owner_id': _userId,
        'title': request.title,
        'status': request.status,
        'buyer_name': request.buyerName,
        'contact_person': request.contactPerson,
        'quantity': request.quantity,
        'budget': request.budget,
        'country': request.country,
        'city': request.city,
        'places': request.places,
        'description': request.description,
        'deadline': request.deadline,
        'category': request.category,
        'media_paths': paths,
      });
    }
    if (rows.isNotEmpty) {
      await _client.from('purchase_requests').upsert(rows);
    }
  }

  @override
  Future<void> saveMessages(List<LocalMessage> messages) async {
    for (final message in messages) {
      if (message.ownerId != _userId) {
        throw StateError('لا يمكنك حفظ رسالة لا تخص حسابك');
      }
      final recipientId =
          message.recipientId ?? await _findRecipientId(message.recipientName);
      if (recipientId == _userId) {
        throw StateError('لا يمكن بدء محادثة مع الحساب نفسه');
      }
      final chatId = await _client.rpc(
        'get_or_create_chat',
        params: {'other_user_id': recipientId},
      ) as String;
      String? attachmentPath;
      if (message.attachmentBase64 != null &&
          !message.attachmentBase64!.startsWith('http')) {
        final mimeType =
            message.attachmentMimeType ?? 'application/octet-stream';
        final extension = _extensionFor(message.attachmentName, mimeType);
        attachmentPath = '$chatId/${message.id}.$extension';
        await _client.storage
            .from('chat-media')
            .uploadBinary(
              attachmentPath,
              base64Decode(message.attachmentBase64!),
              fileOptions: FileOptions(contentType: mimeType, upsert: true),
            );
      } else if (message.attachmentBase64?.startsWith('http') ?? false) {
        attachmentPath = message.attachmentBase64;
      }

      await _client.from('messages').upsert({
        'id': message.id,
        'chat_id': chatId,
        'sender_id': _userId,
        'body': message.body,
        'message_type': message.type,
        'attachment_path': attachmentPath,
        'attachment_name': message.attachmentName,
        'attachment_mime_type': message.attachmentMimeType,
        'sent_at': message.sentAt.toUtc().toIso8601String(),
      });
    }
  }

  Future<void> hideMessages(List<String> ids) async {
    if (ids.isEmpty) return;
    await _client.rpc(
      'set_messages_hidden',
      params: {'message_ids': ids, 'should_hide': true},
    );
  }

  Future<void> restoreMessages(List<String> ids) async {
    if (ids.isEmpty) return;
    await _client.rpc(
      'set_messages_hidden',
      params: {'message_ids': ids, 'should_hide': false},
    );
  }

  Future<void> hideConversation(String recipientName) async {
    final messages = await loadMessages();
    final matchingIds = messages
        .where((message) => message.recipientName == recipientName)
        .map((message) => message.id)
        .toList();
    await hideMessages(matchingIds);
  }

  RealtimeChannel watchMessages(VoidCallback onChange) {
    final channel = _client.channel('user-messages-$_userId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (_) => onChange(),
        )
        .subscribe();
    return channel;
  }

  @override
  Future<void> deleteUserData(String userId) async {}

  @override
  Future<void> deleteOffer(String offerId) async {
    await _client.from('offers').delete().eq('id', offerId);
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    await _client.from('purchase_requests').delete().eq('id', requestId);
  }

  Future<String> _findRecipientId(String recipientName) async {
    final rows = await _client
        .from('profiles')
        .select('id')
        .eq('full_name', recipientName)
        .limit(1);
    if (rows.isEmpty) {
      throw StateError(
        'هذا الحساب تجريبي ولا يملك حساباً مسجلاً للمحادثة. '
        'اختر مستخدماً مسجلاً في Supabase.',
      );
    }
    return rows.first['id'] as String;
  }

  Future<List<String>> _uploadListingMedia({
    required String ownerId,
    required String listingId,
    required List<String> encodedMedia,
  }) async {
    final paths = <String>[];
    for (var index = 0; index < encodedMedia.length; index++) {
      final media = encodedMedia[index];
      if (media.startsWith('http')) {
        final segments = Uri.parse(media).pathSegments;
        final storageIndex = segments.indexOf('listing-media');
        if (storageIndex >= 0 && storageIndex + 1 < segments.length) {
          paths.add(segments.skip(storageIndex + 1).join('/'));
        }
        continue;
      }
      final bytes = base64Decode(media);
      final path = '$ownerId/$listingId/$index.jpg';
      await _client.storage
          .from('listing-media')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      paths.add(path);
    }
    return paths;
  }

  String _extensionFor(String? name, String mimeType) {
    final extension = name?.split('.').last.toLowerCase();
    if (extension != null && extension.length <= 5 && extension != name) {
      return extension;
    }
    return switch (mimeType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'video/mp4' => 'mp4',
      'audio/webm' => 'webm',
      'audio/mp4' => 'm4a',
      _ => 'bin',
    };
  }
}
