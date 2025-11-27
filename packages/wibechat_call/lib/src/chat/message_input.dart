import 'package:flutter/material.dart';
import 'chat_theme.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final ChatThemeData theme;
  final String placeholder;

  const MessageInput({
    super.key,
    required this.onSend,
    required this.theme,
    this.placeholder = 'Type a message...',
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: widget.theme.backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: widget.theme.inputBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: widget.theme.inputTextColor),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: TextStyle(color: widget.theme.inputTextColor.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _handleSend,
            icon: Icon(Icons.send, color: widget.theme.sendButtonColor),
            style: IconButton.styleFrom(
              backgroundColor: widget.theme.sendButtonColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
