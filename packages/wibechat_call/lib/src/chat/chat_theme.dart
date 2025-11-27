import 'package:flutter/material.dart';

class ChatThemeData {
  final Color backgroundColor;
  final Color inputBackgroundColor;
  final Color inputTextColor;
  final Color sendButtonColor;
  final Color sendButtonIconColor;
  final Color messageListBackgroundColor;
  final TextStyle messageTextStyle;
  final TextStyle senderNameTextStyle;
  final TextStyle timestampTextStyle;
  final Color selfMessageBackgroundColor;
  final Color otherMessageBackgroundColor;
  final Color selfMessageTextColor;
  final Color otherMessageTextColor;
  final BorderRadius messageBorderRadius;
  final EdgeInsets messagePadding;
  final EdgeInsets messageMargin;

  const ChatThemeData({
    this.backgroundColor = Colors.white,
    this.inputBackgroundColor = const Color(0xFFF0F0F0),
    this.inputTextColor = Colors.black,
    this.sendButtonColor = Colors.blue,
    this.sendButtonIconColor = Colors.white,
    this.messageListBackgroundColor = Colors.transparent,
    this.messageTextStyle = const TextStyle(fontSize: 14, color: Colors.black),
    this.senderNameTextStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
    this.timestampTextStyle = const TextStyle(fontSize: 10, color: Colors.grey),
    this.selfMessageBackgroundColor = Colors.blue,
    this.otherMessageBackgroundColor = const Color(0xFFE0E0E0),
    this.selfMessageTextColor = Colors.white,
    this.otherMessageTextColor = Colors.black,
    this.messageBorderRadius = const BorderRadius.all(Radius.circular(12)),
    this.messagePadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.messageMargin = const EdgeInsets.symmetric(vertical: 4),
  });
}
