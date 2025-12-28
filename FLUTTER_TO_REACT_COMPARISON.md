# Flutter to React/Next.js Migration Guide

## Side-by-Side Comparison

This document compares your existing **Flutter/Dart** video call implementation with the equivalent **React/Next.js** implementation.

---

## 🔄 Technology Mapping

| Flutter/Dart | React/Next.js |
|--------------|---------------|
| `flutter_livekit` package | `@livekit/components-react` |
| `http` package | `axios` library |
| `StatefulWidget` | `useState` hook |
| `useEffect` lifecycle | `useEffect` hook |
| Dart async/await | JavaScript async/await |
| Material UI | Tailwind CSS |
| Flutter Navigator | Next.js Router |

---

## 📱 Join Screen Comparison

### Flutter (Dart)
```dart
// home_screen.dart (Lines 98-119)

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
```

### React (JavaScript)
```javascript
// lib/livekit.js

export async function fetchToken(room, name) {
  try {
    const response = await axios.get(TOKEN_API, {
      params: { room, name },
    });

    if (response.status === 200 && response.data.token) {
      return response.data.token;
    } else {
      throw new Error('Invalid token response');
    }
  } catch (error) {
    console.error('Error fetching token:', error);
    throw new Error(`Failed to fetch token: ${error.message}`);
  }
}
```

**Key Differences:**
- ✅ Same logic, different syntax
- ✅ Both use async/await
- ✅ Similar error handling

---

## 🎥 Room Connection Comparison

### Flutter (Dart)
```dart
// home_screen.dart (Lines 121-169)

Future<void> _joinRoom() async {
  // Validation...
  
  // Fetch token
  final token = await _fetchToken();

  // Request permissions
  await [Permission.camera, Permission.microphone].request();

  // Configure room
  final roomOptions = RoomOptions(
    adaptiveStream: true,
    dynacast: true,
    defaultVideoPublishOptions: const VideoPublishOptions(simulcast: true),
  );

  final room = Room(roomOptions: roomOptions);
  final listener = room.createListener();

  // Connect
  await room.connect(_kLiveKitUrl, token);

  // Enable camera/mic
  await room.localParticipant?.setCameraEnabled(true);
  await room.localParticipant?.setMicrophoneEnabled(true);

  // Navigate to room screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RoomScreen(room: room, listener: listener),
    ),
  );
}
```

### React (JavaScript)
```jsx
// app/join/page.js

const handleJoin = async (e) => {
  e.preventDefault();
  
  // Validation...

  // Request permissions
  const hasPermission = await requestMediaPermissions();
  if (!hasPermission) {
    throw new Error('Camera and microphone permissions are required');
  }

  // Fetch token
  const token = await fetchToken(roomId.trim(), name.trim());

  // Navigate to room (LiveKit connection happens automatically)
  router.push(
    `/room/${encodeURIComponent(roomId)}?token=${encodeURIComponent(token)}`
  );
};

// app/room/[roomId]/page.js
<LiveKitRoom
  video={true}
  audio={true}
  token={token}
  serverUrl={LIVEKIT_URL}
  onDisconnected={handleDisconnect}
>
  <RoomContent />
</LiveKitRoom>
```

**Key Differences:**
- ✅ React uses declarative `<LiveKitRoom>` component
- ✅ Flutter uses imperative `room.connect()`
- ✅ React handles connection automatically
- ✅ Both support same room options

---

## 🎛️ Control Bar Comparison

### Flutter (Dart)
```dart
// home_screen.dart (Lines 476-486)

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
```

### React (JavaScript)
```javascript
// components/ControlBar.jsx

const toggleMicrophone = async () => {
  if (localParticipant) {
    const enabled = localParticipant.isMicrophoneEnabled;
    await localParticipant.setMicrophoneEnabled(!enabled);
    setIsMicMuted(!enabled);
  }
};

const toggleCamera = async () => {
  if (localParticipant) {
    const enabled = localParticipant.isCameraEnabled;
    await localParticipant.setCameraEnabled(!enabled);
    setIsCameraOff(!enabled);
  }
};
```

**Key Differences:**
- ✅ Nearly identical logic
- ✅ `setState()` in Flutter = `setIsMicMuted()` in React
- ✅ Same LiveKit API

---

## 📹 Participant Video Comparison

### Flutter (Dart)
```dart
// home_screen.dart (Lines 822-948)

class ParticipantVideoWidget extends StatelessWidget {
  final Participant participant;
  final bool isFullscreen;

  @override
  Widget build(BuildContext context) {
    final videoPublication = participant.videoTrackPublications
        .where((pub) => pub.source == TrackSource.camera)
        .firstOrNull;

    final bool isVideoEnabled =
        videoPublication != null &&
        !videoPublication.muted &&
        videoPublication.track != null;

    return Container(
      child: Stack(
        children: [
          if (isVideoEnabled)
            VideoTrackRenderer(
              videoPublication!.track as VideoTrack,
              fit: VideoViewFit.cover,
            )
          else
            // Placeholder UI...
        ],
      ),
    );
  }
}
```

### React (JavaScript)
```jsx
// components/ParticipantVideo.jsx

export default function ParticipantVideo({ track, isFullscreen }) {
  const participant = track.participant;
  const isVideoEnabled = track.publication?.isMuted === false;

  return (
    <div className="relative w-full h-full bg-gray-800">
      {isVideoEnabled ? (
        <VideoTrack
          trackRef={track}
          className="w-full h-full object-cover"
        />
      ) : (
        {/* Placeholder UI... */}
      )}
    </div>
  );
}
```

**Key Differences:**
- ✅ Flutter uses `VideoTrackRenderer`, React uses `<VideoTrack>`
- ✅ Both check if video is enabled before rendering
- ✅ Both show placeholder when camera is off

---

## 🎨 UI Styling Comparison

### Flutter (Dart)
```dart
Container(
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
  ),
  child: Text("Hello"),
)
```

### React (Tailwind CSS)
```jsx
<div className="
  p-8 
  bg-white 
  rounded-3xl 
  shadow-2xl 
  shadow-blue-200/50
">
  Hello
</div>
```

**Key Differences:**
- ✅ Flutter uses `BoxDecoration`, React uses Tailwind classes
- ✅ React is more concise with utility classes
- ✅ Both achieve same visual result

---

## 📂 File Structure Comparison

### Flutter Project
```
lib/
└── features/
    └── home/
        └── view/
            └── home_screen.dart    # Everything in one file
```

### React Project
```
app/
├── join/
│   └── page.js                # Join screen
└── room/
    └── [roomId]/
        └── page.js            # Room screen

components/
├── ParticipantVideo.jsx       # Reusable video tile
└── ControlBar.jsx             # Reusable controls

lib/
└── livekit.js                 # Utilities
```

**Key Differences:**
- ✅ Flutter: Single file approach
- ✅ React: Component-based structure
- ✅ React: Better separation of concerns

---

## 🔐 Permissions Comparison

### Flutter (Dart)
```dart
import 'package:permission_handler/permission_handler.dart';

await [Permission.camera, Permission.microphone].request();
```

### React (JavaScript)
```javascript
export async function requestMediaPermissions() {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: true,
      audio: true,
    });
    
    stream.getTracks().forEach(track => track.stop());
    return true;
  } catch (error) {
    console.error('Permission denied:', error);
    return false;
  }
}
```

**Key Differences:**
- ✅ Flutter uses `permission_handler` package
- ✅ React uses native browser API
- ✅ React requests when calling `getUserMedia`

---

## 🔀 Navigation Comparison

### Flutter (Dart)
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => RoomScreen(room: room),
  ),
);

// Go back
Navigator.pop(context);
```

### React (JavaScript)
```javascript
import { useRouter } from 'next/navigation';

const router = useRouter();

// Navigate
router.push(`/room/${roomId}?token=${token}`);

// Go back
router.back();
```

**Key Differences:**
- ✅ Flutter uses `Navigator` class
- ✅ React uses `useRouter` hook
- ✅ React uses file-based routing

---

## 🔄 State Management Comparison

### Flutter (Dart)
```dart
class _RoomScreenState extends State<RoomScreen> {
  bool _isMicMuted = false;
  
  void _toggleMicrophone() {
    setState(() {
      _isMicMuted = !_isMicMuted;
    });
  }
}
```

### React (JavaScript)
```javascript
function RoomScreen() {
  const [isMicMuted, setIsMicMuted] = useState(false);
  
  const toggleMicrophone = () => {
    setIsMicMuted(!isMicMuted);
  };
}
```

**Key Differences:**
- ✅ Flutter: Class-based with `setState()`
- ✅ React: Functional with hooks
- ✅ Same reactive update pattern

---

## 📊 Feature Parity Matrix

| Feature | Flutter | React | Notes |
|---------|---------|-------|-------|
| Join Screen | ✅ | ✅ | Identical functionality |
| Token Fetching | ✅ | ✅ | Same API endpoint |
| 1-on-1 Calls | ✅ | ✅ | PIP layout supported |
| Group Calls | ✅ | ✅ | Grid layout supported |
| Mic Toggle | ✅ | ✅ | Same API |
| Camera Toggle | ✅ | ✅ | Same API |
| Flip Camera | ✅ | ✅ | Same API |
| Participant Events | ✅ | ✅ | Real-time updates |
| Permissions | ✅ | ✅ | Different approach |
| Animations | ✅ | ✅ | CSS vs Flutter animations |

---

## 🎯 Migration Checklist

### ✅ Completed (in Documentation)
- [x] Join screen with form validation
- [x] Token fetching from API
- [x] Room connection
- [x] Video rendering
- [x] Audio/video controls
- [x] Participant tracking
- [x] PIP layout for 1-on-1
- [x] Grid layout for groups
- [x] Modern UI with Tailwind
- [x] Responsive design

### 🚀 Recommended Additions
- [ ] Screen sharing
- [ ] Chat messages
- [ ] Recording
- [ ] Virtual backgrounds
- [ ] Waiting room
- [ ] Analytics integration

---

## 💡 Key Takeaways

### Similarities
1. **Same LiveKit API**: Both platforms use identical LiveKit methods
2. **Same Architecture**: Client → Token API → LiveKit Server
3. **Same Flow**: Join → Fetch Token → Connect → Video Call
4. **Same Features**: All core functionality is preserved

### Differences
1. **Syntax**: Dart vs JavaScript
2. **Styling**: Material/Container vs Tailwind CSS
3. **State**: setState() vs useState()
4. **Structure**: Single file vs component-based
5. **Routing**: Navigator vs file-based routing

### Advantages of React/Next.js
- ✅ **Better for Web**: Native web platform
- ✅ **Easier Deployment**: Vercel, Netlify, etc.
- ✅ **Rich Ecosystem**: npm packages
- ✅ **SEO Friendly**: Server-side rendering
- ✅ **Hot Reload**: Faster development

### When to Use Each
- **Flutter**: Cross-platform mobile apps (iOS + Android)
- **React/Next.js**: Websites and web applications

---

## 📚 Learning Resources

### Flutter → React Migration
- [React Documentation](https://react.dev/)
- [Next.js Documentation](https://nextjs.org/docs)
- [Tailwind CSS](https://tailwindcss.com/)
- [LiveKit React SDK](https://docs.livekit.io/guides/room/react/)

### Video Call Specific
- [LiveKit Documentation](https://docs.livekit.io/)
- [WebRTC Basics](https://webrtc.org/)
- [Media Devices API](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices)

---

**Last Updated:** December 23, 2025
