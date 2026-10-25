import 'package:flutter/material.dart';

import '../models/local_message.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../widgets/account_avatar.dart';

class MessagesScreen extends StatefulWidget {
  final List<LocalMessage> messages;
  final ValueChanged<String> onOpenConversation;
  final Future<void> Function(List<String>) onDeleteConversations;
  final Map<String, UserProfile> profilesById;

  const MessagesScreen({
    super.key,
    required this.messages,
    required this.onOpenConversation,
    required this.onDeleteConversations,
    this.profilesById = const {},
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final Set<String> _selectedThreadIds = {};

  Future<void> _showConversationActions(
    List<LocalMessage> selectedMessages,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: AppColors.red),
          title: Text(
            selectedMessages.length == 1
                ? 'حذف المحادثة عندي'
                : 'حذف ${selectedMessages.length} محادثات عندي',
          ),
          onTap: () => Navigator.pop(context, 'delete'),
        ),
      ),
    );
    if (action != 'delete' || !mounted) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد حذف المحادثة'),
        content: Text(
          selectedMessages.length == 1
              ? 'سيتم حذف سجل هذه المحادثة من جهازك فقط.'
              : 'سيتم حذف ${selectedMessages.length} محادثات من جهازك فقط.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            key: const ValueKey('confirm-delete-conversations'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;

    try {
      await widget.onDeleteConversations(
        selectedMessages.map((message) => message.recipientName).toList(),
      );
      if (!mounted) return;
      setState(() => _selectedThreadIds.clear());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف المحادثة من جهازك')));
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _toggleSelection(String threadId) {
    setState(() {
      if (!_selectedThreadIds.add(threadId)) {
        _selectedThreadIds.remove(threadId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.darkFg : AppColors.fg;
    final muted = isDark ? AppColors.darkMuted : AppColors.muted;
    final conversations = <String, LocalMessage>{};
    for (final message in widget.messages) {
      final previous = conversations[message.threadId];
      if (previous == null || message.sentAt.isAfter(previous.sentAt)) {
        conversations[message.threadId] = message;
      }
    }
    final latestMessages = conversations.values.toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

    if (latestMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 42, color: muted),
            const SizedBox(height: 12),
            Text('لا توجد محادثات بعد', style: TextStyle(color: foreground)),
          ],
        ),
      );
    }

    final isSelecting = _selectedThreadIds.isNotEmpty;
    final selectedMessages = latestMessages
        .where((message) => _selectedThreadIds.contains(message.threadId))
        .toList();

    return Column(
      children: [
        if (isSelecting)
          Material(
            color: isDark ? AppColors.darkPanel : AppColors.panel,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16),
                    child: Text(
                      'تم تحديد ${_selectedThreadIds.length} محادثة',
                      style: TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('delete-selected-conversations'),
                  tooltip: 'حذف المحدد',
                  onPressed: () => _showConversationActions(selectedMessages),
                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                ),
                IconButton(
                  tooltip: 'إلغاء التحديد',
                  onPressed: () => setState(_selectedThreadIds.clear),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: latestMessages.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final message = latestMessages[index];
              final profile = resolveAccountProfile(
                widget.profilesById,
                name: message.recipientName,
              );
              final recipientRole =
                  profile?.role ??
                  MockData.getCompanyByName(message.recipientName)?.type ??
                  'مورد';
              final isSelected = _selectedThreadIds.contains(message.threadId);
              return Card(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.08)
                    : null,
                child: ListTile(
                  key: ValueKey('conversation-${message.threadId}'),
                  onLongPress: () => _toggleSelection(message.threadId),
                  onTap: () {
                    if (isSelecting) {
                      _toggleSelection(message.threadId);
                    } else {
                      widget.onOpenConversation(message.recipientName);
                    }
                  },
                  leading: isSelecting
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleSelection(message.threadId),
                        )
                      : AccountAvatar(
                          key: ValueKey(
                            'conversation-avatar-${message.threadId}',
                          ),
                          name: message.recipientName,
                          avatarBase64: profile?.avatarBase64,
                          role: recipientRole,
                        ),
                  title: Text(
                    message.recipientName,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    _messagePreview(message),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: muted),
                  ),
                  trailing: Text(
                    '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _messagePreview(LocalMessage message) {
    if (message.body.isNotEmpty) return message.body;
    return switch (message.type) {
      'image' => '📷 صورة',
      'video' => '🎬 فيديو',
      'audio' => '🎙️ رسالة صوتية',
      _ => message.subject,
    };
  }
}
