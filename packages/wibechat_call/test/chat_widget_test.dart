import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wibechat_call/wibechat_call.dart';

void main() {
  testWidgets('ChatView renders messages and input', (WidgetTester tester) async {
    final messages = [
      ChatMessage(
        id: '1',
        text: 'Hello',
        sender: ChatUser(id: 'u1', name: 'User 1'),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isSelf: false,
      ),
      ChatMessage(
        id: '2',
        text: 'Hi there',
        sender: ChatUser(id: 'u2', name: 'Me'),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isSelf: true,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            messages: messages,
            onSend: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Hi there'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('ChatView triggers onSend when message is sent', (WidgetTester tester) async {
    String? sentMessage;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            messages: [],
            onSend: (msg) => sentMessage = msg,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'New message');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(sentMessage, 'New message');
  });

  testWidgets('ChatView applies custom theme', (WidgetTester tester) async {
    const customColor = Colors.red;
    const theme = ChatThemeData(
      sendButtonColor: customColor,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            messages: [],
            onSend: (_) {},
            theme: theme,
          ),
        ),
      ),
    );

    final iconButton = tester.widget<IconButton>(find.byType(IconButton));
    final icon = iconButton.icon as Icon;
    expect(icon.color, customColor);
  });
}
