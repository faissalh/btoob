import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/local_message.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/account_avatar.dart';

class PrivateChatScreen extends StatefulWidget {
  final String ownerId;
  final String recipientName;
  final String? recipientId;
  final List<LocalMessage> messages;
  final Future<void> Function(LocalMessage) onSend;
  final Future<List<LocalMessage>> Function(List<String>) onDeleteMessages;
  final Future<void> Function(List<LocalMessage>) onRestoreMessages;
  final VoidCallback onOpenRecipientProfile;
  final UserProfile? ownerProfile;
  final UserProfile? recipientProfile;

  const PrivateChatScreen({
    super.key,
    required this.ownerId,
    required this.recipientName,
    this.recipientId,
    required this.messages,
    required this.onSend,
    required this.onDeleteMessages,
    required this.onRestoreMessages,
    required this.onOpenRecipientProfile,
    this.ownerProfile,
    this.recipientProfile,
  });

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  static const _maxAttachmentBytes = 2 * 1024 * 1024;
  static const _maxRecordingDuration = Duration(seconds: 45);

  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  final _recorder = AudioRecorder();
  final List<LocalMessage> _messages = [];
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool _isRecording = false;
  bool _isSending = false;
  _PendingAttachment? _pendingAttachment;
  final Set<String> _selectedMessageIds = {};

  @override
  void initState() {
    super.initState();
    _messages.addAll(widget.messages);
    _messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _chooseAttachment() async {
    final kind = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('اختيار صورة'),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('اختيار فيديو'),
              onTap: () => Navigator.pop(context, 'video'),
            ),
          ],
        ),
      ),
    );
    if (kind == null || !mounted) return;

    try {
      final file = kind == 'image'
          ? await _imagePicker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
              maxWidth: 1600,
            )
          : await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > _maxAttachmentBytes) {
        _showError('حجم المرفق أكبر من 2 ميغابايت في النسخة المحلية');
        return;
      }
      setState(() {
        _pendingAttachment = _PendingAttachment(
          name: file.name,
          mimeType: kind == 'image' ? _imageMimeType(file.name) : 'video/mp4',
          type: kind,
          bytes: bytes,
        );
      });
    } on PlatformException {
      if (mounted) _showError('تعذر اختيار الملف، حاول مرة أخرى');
    }
  }

  String _imageMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
      return;
    }

    try {
      if (!await _recorder.hasPermission()) {
        _showError('يلزم السماح باستخدام الميكروفون لتسجيل رسالة صوتية');
        return;
      }
      final path = kIsWeb
          ? 'voice-${DateTime.now().microsecondsSinceEpoch}.webm'
          : '${(await getTemporaryDirectory()).path}/voice-${DateTime.now().microsecondsSinceEpoch}.m4a';
      await _recorder.start(
        RecordConfig(
          encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc,
          bitRate: 32000,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _recordingSeconds++);
        if (_recordingSeconds >= _maxRecordingDuration.inSeconds) {
          _stopRecording();
        }
      });
    } on Exception {
      if (mounted) _showError('تعذر بدء التسجيل الصوتي');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    try {
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() => _isRecording = false);
      if (path == null) {
        _showError('لم يتم إنشاء تسجيل صوتي');
        return;
      }
      final bytes = await XFile(path).readAsBytes();
      if (bytes.isEmpty) {
        _showError('التسجيل الصوتي فارغ');
        return;
      }
      if (bytes.length > _maxAttachmentBytes) {
        _showError('حجم التسجيل أكبر من 2 ميغابايت');
        return;
      }
      setState(() {
        _pendingAttachment = _PendingAttachment(
          name: 'رسالة صوتية',
          mimeType: kIsWeb ? 'audio/webm' : 'audio/mp4',
          type: 'audio',
          bytes: bytes,
        );
      });
    } on Exception {
      if (mounted) {
        setState(() => _isRecording = false);
        _showError('تعذر حفظ التسجيل الصوتي');
      }
    }
  }

  Future<void> _sendMessage() async {
    final body = _textController.text.trim();
    final attachment = _pendingAttachment;
    if ((body.isEmpty && attachment == null) || _isSending || _isRecording) {
      return;
    }
    setState(() => _isSending = true);
    final message = LocalMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      ownerId: widget.ownerId,
      senderId: widget.ownerId,
      recipientId: widget.recipientId,
      recipientName: widget.recipientName,
      subject: 'محادثة خاصة',
      body: body,
      sentAt: DateTime.now(),
      type: attachment?.type ?? 'text',
      attachmentName: attachment?.name,
      attachmentMimeType: attachment?.mimeType,
      attachmentBase64: attachment == null
          ? null
          : base64Encode(attachment.bytes),
    );
    try {
      await widget.onSend(message);
      if (!mounted) return;
      setState(() {
        _messages.add(message);
        _textController.clear();
        _pendingAttachment = null;
      });
      await _scrollToBottom();
    } on StateError catch (error) {
      if (mounted) _showError(error.message);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _scrollToBottom() async {
    await WidgetsBinding.instance.endOfFrame;
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatRecordingDuration(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (!_selectedMessageIds.add(messageId)) {
        _selectedMessageIds.remove(messageId);
      }
    });
  }

  Future<void> _showMessageActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: AppColors.red),
          title: Text(
            _selectedMessageIds.length == 1
                ? 'حذف الرسالة عندي'
                : 'حذف ${_selectedMessageIds.length} رسائل عندي',
          ),
          onTap: () => Navigator.pop(context, 'delete'),
        ),
      ),
    );
    if (action != 'delete' || !mounted) return;

    try {
      final deleted = await widget.onDeleteMessages(
        _selectedMessageIds.toList(),
      );
      if (deleted.isEmpty || !mounted) return;
      final deletedIds = deleted.map((message) => message.id).toSet();
      setState(() {
        _messages.removeWhere((message) => deletedIds.contains(message.id));
        _selectedMessageIds.clear();
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              deleted.length == 1
                  ? 'تم حذف الرسالة من جهازك'
                  : 'تم حذف ${deleted.length} رسائل من جهازك',
            ),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () => _undoDelete(deleted),
            ),
          ),
        );
    } on StateError catch (error) {
      if (mounted) _showError(error.message);
    }
  }

  Future<void> _undoDelete(List<LocalMessage> deleted) async {
    try {
      await widget.onRestoreMessages(deleted);
      if (!mounted) return;
      final existingIds = _messages.map((message) => message.id).toSet();
      setState(() {
        _messages.addAll(
          deleted.where((message) => !existingIds.contains(message.id)),
        );
        _messages.sort(
          (first, second) => first.sentAt.compareTo(second.sentAt),
        );
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تمت استعادة الرسالة')));
    } on StateError catch (error) {
      if (mounted) _showError(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelecting = _selectedMessageIds.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: isSelecting
            ? Text('تم تحديد ${_selectedMessageIds.length} رسائل')
            : TextButton(
                key: const ValueKey('chat-recipient-profile'),
                onPressed: widget.onOpenRecipientProfile,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AccountAvatar(
                      key: const ValueKey('chat-recipient-avatar'),
                      name:
                          widget.recipientProfile?.fullName ??
                          widget.recipientName,
                      avatarBase64: widget.recipientProfile?.avatarBase64,
                      role: widget.recipientProfile?.role ?? 'مورد',
                      size: 34,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.recipientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.open_in_new, size: 16),
                  ],
                ),
              ),
        actions: isSelecting
            ? [
                IconButton(
                  key: const ValueKey('delete-selected-messages'),
                  tooltip: 'حذف المحدد',
                  onPressed: _showMessageActions,
                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                ),
                IconButton(
                  tooltip: 'إلغاء التحديد',
                  onPressed: () => setState(_selectedMessageIds.clear),
                  icon: const Icon(Icons.close),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'ابدأ محادثة خاصة مع ${widget.recipientName}',
                      style: TextStyle(
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),
                  )
                : ListView.builder(
                    key: const ValueKey('private-chat-messages'),
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _messageBubble(
                      _messages[index],
                      isDark,
                      isSelected: _selectedMessageIds.contains(
                        _messages[index].id,
                      ),
                    ),
                  ),
          ),
          _composer(isDark),
        ],
      ),
    );
  }

  Widget _messageBubble(
    LocalMessage message,
    bool isDark, {
    required bool isSelected,
  }) {
    final background = isDark ? AppColors.darkPanel : Colors.white;
    final foreground = isDark ? AppColors.darkFg : AppColors.fg;
    final isMine = (message.senderId ?? message.ownerId) == widget.ownerId;
    final avatarProfile = isMine
        ? widget.ownerProfile
        : widget.recipientProfile;
    final avatarName =
        avatarProfile?.fullName ?? (isMine ? 'المستخدم' : widget.recipientName);
    final avatar = AccountAvatar(
      key: ValueKey('chat-message-avatar-${message.id}'),
      name: avatarName,
      avatarBase64: avatarProfile?.avatarBase64,
      role: avatarProfile?.role ?? (isMine ? 'مشتري' : 'مورد'),
      size: 30,
    );
    final attachment = message.attachmentBase64;
    final attachmentUri = attachment == null ? null : Uri.tryParse(attachment);
    final attachmentUrl =
        attachmentUri != null &&
        (attachmentUri.scheme == 'http' || attachmentUri.scheme == 'https');
    final attachmentBytes = attachment == null || attachmentUrl
        ? null
        : base64Decode(attachment);

    return GestureDetector(
      key: ValueKey('chat-message-${message.id}'),
      onLongPress: () => _toggleMessageSelection(message.id),
      onTap: _selectedMessageIds.isNotEmpty
          ? () => _toggleMessageSelection(message.id)
          : null,
      child: Align(
        alignment: isMine
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine) ...[avatar, const SizedBox(width: 8)],
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.16)
                    : background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkLine : AppColors.line,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.body.isNotEmpty)
                    Text(
                      message.body,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: foreground),
                    ),
                  if (attachmentBytes != null || attachmentUrl) ...[
                    if (message.body.isNotEmpty) const SizedBox(height: 8),
                    if (message.type == 'image')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: attachmentUrl
                            ? Image.network(
                                attachment!,
                                width: 260,
                                fit: BoxFit.cover,
                              )
                            : Image.memory(
                                Uint8List.fromList(attachmentBytes!),
                                width: 260,
                                fit: BoxFit.cover,
                              ),
                      )
                    else if (message.type == 'audio')
                      _AudioMessage(
                        bytes: attachmentBytes,
                        url: attachmentUrl ? attachment : null,
                        mimeType: message.attachmentMimeType,
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.video_file_outlined,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              message.attachmentName ?? 'فيديو مرفق',
                              style: TextStyle(color: foreground),
                            ),
                          ),
                        ],
                      ),
                  ],
                  const SizedBox(height: 5),
                  Text(
                    _formatMessageTime(message.sentAt),
                    style: TextStyle(
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isMine) ...[const SizedBox(width: 8), avatar],
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime sentAt) =>
      '${sentAt.hour.toString().padLeft(2, '0')}:${sentAt.minute.toString().padLeft(2, '0')}';

  Widget _composer(bool isDark) {
    final attachment = _pendingAttachment;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkPanel : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkLine : AppColors.line,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (attachment != null)
              ListTile(
                dense: true,
                leading: Icon(
                  attachment.type == 'image'
                      ? Icons.image_outlined
                      : attachment.type == 'video'
                      ? Icons.video_file_outlined
                      : Icons.mic,
                ),
                title: Text(attachment.name),
                trailing: IconButton(
                  tooltip: 'إزالة المرفق',
                  onPressed: () => setState(() => _pendingAttachment = null),
                  icon: const Icon(Icons.close),
                ),
              ),
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'جارٍ التسجيل ${_formatRecordingDuration(_recordingSeconds)} · اضغط الميكروفون للإيقاف',
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  key: const ValueKey('chat-attach'),
                  tooltip: 'إضافة صورة أو فيديو',
                  onPressed: _isRecording ? null : _chooseAttachment,
                  icon: const Icon(Icons.attach_file),
                ),
                IconButton(
                  key: const ValueKey('chat-record'),
                  tooltip: _isRecording ? 'إيقاف التسجيل' : 'تسجيل صوتي',
                  color: _isRecording ? AppColors.red : null,
                  onPressed: _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic_none),
                ),
                Expanded(
                  child: TextField(
                    key: const ValueKey('chat-composer'),
                    controller: _textController,
                    minLines: 1,
                    maxLines: 4,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالة...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  key: const ValueKey('chat-send'),
                  tooltip: 'إرسال',
                  onPressed: _isSending ? null : _sendMessage,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingAttachment {
  final String name;
  final String mimeType;
  final String type;
  final Uint8List bytes;

  const _PendingAttachment({
    required this.name,
    required this.mimeType,
    required this.type,
    required this.bytes,
  });
}

class _AudioMessage extends StatefulWidget {
  final List<int>? bytes;
  final String? url;
  final String? mimeType;

  const _AudioMessage({required this.bytes, this.url, required this.mimeType});

  @override
  State<_AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<_AudioMessage> {
  final _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    try {
      if (_playing) {
        await _player.pause();
      } else {
        if (widget.url != null) {
          await _player.play(UrlSource(widget.url!));
        } else if (widget.bytes != null) {
          await _player.play(
            BytesSource(
              Uint8List.fromList(widget.bytes!),
              mimeType: widget.mimeType,
            ),
          );
        }
      }
      if (mounted) setState(() => _playing = !_playing);
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تشغيل الرسالة الصوتية')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        key: const ValueKey('audio-play'),
        onPressed: _toggle,
        icon: Icon(_playing ? Icons.pause_circle : Icons.play_circle),
      ),
      const Text('رسالة صوتية'),
    ],
  );
}
