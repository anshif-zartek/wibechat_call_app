
class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;

  const ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final ChatUser sender;
  final int timestamp;
  final bool isSelf;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isSelf = false,
  });
}
