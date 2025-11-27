import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveKit Modern Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.blue.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          labelStyle: const TextStyle(color: Colors.blueGrey),
          hintStyle: TextStyle(color: Colors.blueGrey.withValues(alpha: 0.5)),
        ),
      ),
      home: const JoinScreen(),
    );
  }
}

const String _kLiveKitUrl = 'wss://zartek-wibechat-4qcjdtw4.livekit.cloud';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> with SingleTickerProviderStateMixin {
  bool _isBusy = false;
  final _tokenController = TextEditingController();
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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuad,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      await [Permission.camera, Permission.microphone].request();

      final roomOptions = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        defaultVideoPublishOptions: const VideoPublishOptions(
          simulcast: true,
        ),
        defaultAudioPublishOptions: const AudioPublishOptions(
          name: 'audio_track',
        ),
      );

      final room = Room(roomOptions: roomOptions);
      final listener = room.createListener();

      await room.connect(
        _kLiveKitUrl,
        _tokenController.text.trim(),
      );

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
          pageBuilder: (_, __, ___) => RoomScreen(room: room, listener: listener),
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
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          height: 120,

                        ),
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
                          "Enter your access token to connect",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _tokenController,
                          style: const TextStyle(color: Color(0xFF0D47A1)), // Dark Blue
                          decoration: const InputDecoration(
                            labelText: 'Access Token',
                            hintText: 'Paste token here...',
                            prefixIcon: Icon(Icons.vpn_key_rounded, color: Colors.blueAccent),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Token is required';
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
                                    colors: [Colors.blue, Color(0xFF0D47A1)], // Blue to Dark Blue
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

class RoomScreen extends StatefulWidget {
  final Room room;
  final EventsListener<RoomEvent> listener;

  const RoomScreen({
    super.key,
    required this.room,
    required this.listener,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  List<Participant> participants = [];
  bool _isMicMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _updateParticipantList();
    widget.room.addListener(_onRoomDidUpdate);
    _setUpListeners();
  }

  void _setUpListeners() {
    widget.listener
      ..on<ParticipantConnectedEvent>((_) => _updateParticipantList())
      ..on<ParticipantDisconnectedEvent>((_) => _updateParticipantList())
      ..on<TrackSubscribedEvent>((_) => _updateParticipantList())
      ..on<TrackUnsubscribedEvent>((_) => _updateParticipantList())
      ..on<TrackMutedEvent>((_) => _updateParticipantList())
      ..on<TrackUnmutedEvent>((_) => _updateParticipantList())
      ..on<LocalTrackPublishedEvent>((_) => _updateParticipantList())
      ..on<LocalTrackUnpublishedEvent>((_) => _updateParticipantList());
  }

  void _onRoomDidUpdate() {
    _updateParticipantList();
  }

  void _updateParticipantList() {
    setState(() {
      participants = [
        if (widget.room.localParticipant != null) widget.room.localParticipant!,
        ...widget.room.remoteParticipants.values,
      ];
    });
  }

  Future<void> _toggleMicrophone() async {
    final newState = !_isMicMuted;
    await widget.room.localParticipant?.setMicrophoneEnabled(!newState);
    setState(() => _isMicMuted = newState);
  }

  Future<void> _toggleCamera() async {
    final newState = !_isCameraOff;
    await widget.room.localParticipant?.setCameraEnabled(!newState);
    setState(() => _isCameraOff = newState);
  }

  Future<void> _flipCamera() async {
    final localParticipant = widget.room.localParticipant;
    if (localParticipant == null) return;

    final videoTrack = localParticipant.videoTrackPublications
        .where((pub) => pub.source == TrackSource.camera)
        .firstOrNull;

    if (videoTrack?.track is LocalVideoTrack) {
      final track = videoTrack!.track as LocalVideoTrack;
      try {
        final devices = await Hardware.instance.enumerateDevices();
        final cameras = devices.where((d) => d.kind == 'videoinput').toList();
        
        if (cameras.length < 2) return;
        
        final currentOptions = track.currentOptions;
        String? currentDeviceId;
        if (currentOptions is CameraCaptureOptions) {
          currentDeviceId = currentOptions.deviceId;
        }
        
        int currentIndex = cameras.indexWhere((d) => d.deviceId == currentDeviceId);
        int nextIndex = (currentIndex + 1) % cameras.length;
        final nextCamera = cameras[nextIndex];
        
        await track.switchCamera(nextCamera.deviceId);
      } catch (e) {
        debugPrint('Error switching camera: $e');
      }
    }
  }

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    widget.room.removeListener(_onRoomDidUpdate);
    widget.listener.dispose();
    widget.room.disconnect();
    super.dispose();
  }

  bool get _isOneOnOneCall => participants.length == 2;

  @override
  Widget build(BuildContext context) {
    final isOneOnOne = _isOneOnOneCall;
    final remoteParticipants = participants.where((p) => p is! LocalParticipant).toList();
    final localParticipant = participants.firstWhere(
      (p) => p is LocalParticipant,
      orElse: () => participants.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          // Main Video Area
          if (isOneOnOne && remoteParticipants.isNotEmpty)
            Positioned.fill(
              child: ParticipantVideoWidget(
                participant: remoteParticipants.first,
                isFullscreen: true,
              ),
            )
          else if (!isOneOnOne && participants.isNotEmpty)
            Positioned.fill(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(8, 100, 8, 100),
                itemCount: participants.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  return ParticipantVideoWidget(
                    participant: participants[index],
                    isFullscreen: false,
                  );
                },
              ),
            )
          else
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.blueAccent),
                  SizedBox(height: 16),
                  Text(
                    "Waiting for others...",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            ),

          // PIP View (Local)
          if (isOneOnOne && remoteParticipants.isNotEmpty)
            Positioned(
              top: 60,
              right: 16,
              child: GestureDetector(
                onTap: _flipCamera,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ParticipantVideoWidget(
                      participant: localParticipant,
                      isFullscreen: false,
                    ),
                  ),
                ),
              ),
            ),

          // Top Info Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.room.name ?? 'Live Room',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${participants.length} online',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: _endCall,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Control Bar
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildControlButton(
                        icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        isActive: !_isMicMuted,
                        onPressed: _toggleMicrophone,
                        activeColor: Colors.white,
                        inactiveColor: Colors.redAccent,
                      ),
                      _buildControlButton(
                        icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                        isActive: !_isCameraOff,
                        onPressed: _toggleCamera,
                        activeColor: Colors.white,
                        inactiveColor: Colors.redAccent,
                      ),
                      _buildControlButton(
                        icon: Icons.flip_camera_ios_rounded,
                        isActive: true,
                        onPressed: _flipCamera,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white,
                      ),
                      _buildControlButton(
                        icon: Icons.call_end_rounded,
                        isActive: false,
                        onPressed: _endCall,
                        activeColor: Colors.white,
                        inactiveColor: Colors.redAccent,
                        isEndCall: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required Color activeColor,
    required Color inactiveColor,
    bool isEndCall = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isEndCall 
                ? Colors.redAccent 
                : (isActive ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.9)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isEndCall 
                ? Colors.white 
                : (isActive ? Colors.white : Colors.black),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class ParticipantVideoWidget extends StatelessWidget {
  final Participant participant;
  final bool isFullscreen;

  const ParticipantVideoWidget({
    super.key,
    required this.participant,
    this.isFullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    TrackPublication? videoPublication;
    final cameraTracks = participant.videoTrackPublications
        .where((pub) => pub.source == TrackSource.camera);

    if (cameraTracks.isNotEmpty) {
      videoPublication = cameraTracks.first;
    } else if (participant.videoTrackPublications.isNotEmpty) {
      videoPublication = participant.videoTrackPublications.first;
    }

    final bool isVideoEnabled = videoPublication != null &&
        !videoPublication.muted &&
        videoPublication.track != null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: isFullscreen ? BorderRadius.zero : BorderRadius.circular(16),
        border: isFullscreen ? null : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (isVideoEnabled)
            Positioned.fill(
              child: VideoTrackRenderer(
                videoPublication!.track as VideoTrack,
                fit: VideoViewFit.cover,
              ),
            )
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isFullscreen ? 30 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white24,
                      size: isFullscreen ? 80 : 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    participant is LocalParticipant
                        ? "You"
                        : participant.identity,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: isFullscreen ? 18 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          if (!isFullscreen)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      participant is LocalParticipant
                          ? "You"
                          : participant.identity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      participant.isMicrophoneEnabled() 
                          ? Icons.mic_rounded 
                          : Icons.mic_off_rounded,
                      color: participant.isMicrophoneEnabled() 
                          ? Colors.greenAccent 
                          : Colors.redAccent,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}