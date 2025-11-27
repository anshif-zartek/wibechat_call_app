import 'package:flutter/material.dart';
import 'chat_data.dart';
import 'chat_theme.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ChatThemeData theme;
  final ScrollController? scrollController;
  final Widget Function(BuildContext, ChatMessage)? messageBuilder;

  const MessageList({
    super.key,
    required this.messages,
    required this.theme,
    this.scrollController,
    this.messageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.messageListBackgroundColor,
      child: ListView.builder(
        controller: scrollController,
        reverse: true, // Show latest messages at the bottom
        padding: theme.messagePadding,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          if (messageBuilder != null) {
            return messageBuilder!(context, message);
          }
          return _buildDefaultMessageItem(message);
        },
      ),
    );
  }

  Widget _buildDefaultMessageItem(ChatMessage message) {
    final isSelf = message.isSelf;
    final align = isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isSelf ? theme.selfMessageBackgroundColor : theme.otherMessageBackgroundColor;
    final textColor = isSelf ? theme.selfMessageTextColor : theme.otherMessageTextColor;

    return Container(
      margin: theme.messageMargin,
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (!isSelf) ...[
            Text(
              message.sender.name,
              style: theme.senderNameTextStyle,
            ),
            const SizedBox(height: 2),
          ],
          Container(
            padding: theme.messagePadding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: theme.messageBorderRadius,
            ),
            child: Text(
              message.text,
              style: theme.messageTextStyle.copyWith(color: textColor),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatTimestamp(message.timestamp),
            style: theme.timestampTextStyle,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
