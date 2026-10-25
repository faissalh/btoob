class LocalMessage {
  final String id;
  final String ownerId;
  final String? senderId;
  final String? recipientId;
  final String? chatId;
  final String recipientName;
  final String subject;
  final String body;
  final DateTime sentAt;
  final String type;
  final String? attachmentName;
  final String? attachmentMimeType;
  final String? attachmentBase64;

  const LocalMessage({
    required this.id,
    required this.ownerId,
    this.senderId,
    this.recipientId,
    this.chatId,
    required this.recipientName,
    required this.subject,
    required this.body,
    required this.sentAt,
    this.type = 'text',
    this.attachmentName,
    this.attachmentMimeType,
    this.attachmentBase64,
  });

  String get threadId => '$ownerId::$recipientName';

  Map<String, Object?> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'senderId': senderId,
    'recipientId': recipientId,
    'chatId': chatId,
    'recipientName': recipientName,
    'subject': subject,
    'body': body,
    'sentAt': sentAt.toIso8601String(),
    'type': type,
    'attachmentName': attachmentName,
    'attachmentMimeType': attachmentMimeType,
    'attachmentBase64': attachmentBase64,
  };

  factory LocalMessage.fromJson(Map<String, Object?> json) => LocalMessage(
    id: json['id']! as String,
    ownerId: json['ownerId']! as String,
    senderId: json['senderId'] as String?,
    recipientId: json['recipientId'] as String?,
    chatId: json['chatId'] as String?,
    recipientName: json['recipientName']! as String,
    subject: json['subject']! as String,
    body: json['body']! as String,
    sentAt: DateTime.parse(json['sentAt']! as String),
    type: json['type'] as String? ?? 'text',
    attachmentName: json['attachmentName'] as String?,
    attachmentMimeType: json['attachmentMimeType'] as String?,
    attachmentBase64: json['attachmentBase64'] as String?,
  );
}
