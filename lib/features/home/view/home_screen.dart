import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wibechat_call_app/features/home/view/room_screen.dart';



const String _kLiveKitUrl = 'wss://call.wibechat.com';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isBusy = false;
  final _nameController = TextEditingController();
  final _roomController = TextEditingController(text: 'zartek-room');
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutQuad),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<String?> _fetchToken() async {
    try {
      final name = _nameController.text.trim();
      final room = _roomController.text.trim();

      final url = Uri.parse(
        'https://getlivekittoken-3xpiwheqja-uc.a.run.app?room=$room&name=$name',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['token'] as String?;
      } else {
        throw Exception('Failed to fetch token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching token: $e');
      rethrow;
    }
  }

  Future<void> _joinRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      // Fetch token from API
      final token = await _fetchToken();

      if (token == null || token.isEmpty) {
        throw Exception('Invalid token received');
      }

      await [Permission.camera, Permission.microphone].request();

      final roomOptions = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        defaultVideoPublishOptions: const VideoPublishOptions(simulcast: true),
        defaultAudioPublishOptions: const AudioPublishOptions(
          name: 'audio_track',
        ),
      );

      final room = Room(roomOptions: roomOptions);
      final listener = room.createListener();

      await room.connect(_kLiveKitUrl, token);

      try {
        await room.localParticipant?.setCameraEnabled(true);
        await room.localParticipant?.setMicrophoneEnabled(true);
      } catch (e) {
        debugPrint('Could not enable camera/mic: $e');
      }

      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              RoomScreen(room: room, listener: listener),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    } catch (e) {
      debugPrint('Error joining room: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFE3F2FD), // Light Blue 50
              Color(0xFFBBDEFB), // Blue 100
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset("assets/images/logo.png", height: 120),
                        const SizedBox(height: 30),
                        const Text(
                          "Join Room",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0), // Dark Blue
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter your name and room ID to join",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Color(0xFF0D47A1)),
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter your name...',
                            prefixIcon: Icon(
                              Icons.person_rounded,
                              color: Colors.blueAccent,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                          enabled: !_isBusy,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _roomController,
                          style: const TextStyle(color: Color(0xFF0D47A1)),
                          decoration: const InputDecoration(
                            labelText: 'Room ID',
                            hintText: 'Enter room ID...',
                            prefixIcon: Icon(
                              Icons.meeting_room_rounded,
                              color: Colors.blueAccent,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Room ID is required';
                            }
                            return null;
                          },
                          enabled: !_isBusy,
                        ),
                        const SizedBox(height: 40),
                        _isBusy
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blueAccent,
                                ),
                              )
                            : Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.blue,
                                      Color(0xFF0D47A1),
                                    ], // Blue to Dark Blue
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _joinRoom,
                                    borderRadius: BorderRadius.circular(16),
                                    child: const Center(
                                      child: Text(
                                        "JOIN NOW",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                        // Debug-only button to test Analytics
                        if (kDebugMode)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 10,
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    // Send Firebase purchase event with ₹50,000
                                    FirebaseAnalytics.instance.logEvent(name: "test event");
                                    await FirebaseAnalytics.instance.logPurchase(
                                      currency: 'INR',
                                      value: 50000,
                                      transactionId: 'test_${DateTime.now().millisecondsSinceEpoch}',
                                      items: [
                                        AnalyticsEventItem(
                                          itemId: 'test_item_001',
                                          itemName: 'Test Product',
                                          itemCategory: 'test_category',
                                          price: 50000,
                                          quantity: 1,
                                        ),
                                      ],
                                    );


                                    print("✅ Purchase event sent: ₹50,000");

                                    // Show confirmation
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("✅ Purchase event sent! Check Firebase in 1-2 minutes."),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    print("❌ Error: $e");

                                  }},
                                icon: Icon(
                                  Icons.bug_report,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Test Analytics (Debug)",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




