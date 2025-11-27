import 'package:flutter/material.dart';
import 'chat_data.dart';
import 'chat_theme.dart';
import 'message_list.dart';
import 'message_input.dart';

class ChatView extends StatelessWidget {
  final List<ChatMessage> messages;
  final Function(String) onSend;
  final ChatThemeData theme;
  final Widget Function(BuildContext, ChatMessage)? messageBuilder;
  final Widget? inputBuilder;
  final String inputPlaceholder;

  const ChatView({
    super.key,
    required this.messages,
    required this.onSend,
    this.theme = const ChatThemeData(),
    this.messageBuilder,
    this.inputBuilder,
    this.inputPlaceholder = 'Type a message...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: MessageList(
              messages: messages,
              theme: theme,
              messageBuilder: messageBuilder,
            ),
          ),
          if (inputBuilder != null)
            inputBuilder!
          else
            MessageInput(
              onSend: onSend,
              theme: theme,
              placeholder: inputPlaceholder,
            ),
        ],
      ),
    );
  }
}
