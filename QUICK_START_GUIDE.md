# Video Call Integration - Quick Start Guide

## 🚀 5-Minute Setup

### 1. Create Next.js Project

```bash
npx create-next-app@latest video-call-app --typescript --tailwind --app
cd video-call-app
npm install @livekit/components-react livekit-client axios
```

### 2. Create Environment Variables

Create `.env.local`:

```env
NEXT_PUBLIC_LIVEKIT_URL=wss://call.wibechat.com
NEXT_PUBLIC_TOKEN_API=https://getlivekittoken-3xpiwheqja-uc.a.run.app
```

### 3. Update Firebase Functions (CORS)

In `functions/index.js`, add to allowedOrigins:

```javascript
const allowedOrigins = [
  "https://wibechat-demo.web.app",
  "http://localhost:5000",
  "http://localhost:3000", // ← Add this for Next.js dev
];
```

Deploy:
```bash
firebase deploy --only functions
```

### 4. File Structure

Create these files:

```
app/
├── page.js                     # Redirect to /join
├── join/
│   └── page.js                 # Join screen (form)
├── room/
│   └── [roomId]/
│       └── page.js             # Video room
components/
├── ParticipantVideo.jsx        # Video tile
└── ControlBar.jsx              # Call controls
lib/
└── livekit.js                  # Utilities
```

### 5. Copy Code

Copy all code from `VIDEO_CALL_INTEGRATION_DOCUMENTATION.md` into respective files.

### 6. Run Development Server

```bash
npm run dev
```

Visit: http://localhost:3000

---

## 🎯 How It Works

### User Flow

```
1. User visits /join
   ↓
2. Enters name + room ID
   ↓
3. App fetches token from API
   ↓
4. Redirects to /room/[roomId]
   ↓
5. LiveKit connects to wss://call.wibechat.com
   ↓
6. Video call starts! 🎥
```

### Architecture

```
React Client → Token API (Firebase) → LiveKit Server → Participants
```

---

## 📝 Key APIs

### 1. Fetch Token

```javascript
import axios from 'axios';

const response = await axios.get(
  'https://getlivekittoken-3xpiwheqja-uc.a.run.app',
  { params: { room: 'my-room', name: 'John' } }
);

const token = response.data.token;
```

### 2. Connect to Room

```jsx
import { LiveKitRoom } from '@livekit/components-react';

<LiveKitRoom
  token={token}
  serverUrl="wss://call.wibechat.com"
  video={true}
  audio={true}
>
  {/* Your UI */}
</LiveKitRoom>
```

### 3. Control Mic/Camera

```javascript
import { useLocalParticipant } from '@livekit/components-react';

const { localParticipant } = useLocalParticipant();

// Toggle microphone
await localParticipant.setMicrophoneEnabled(false);

// Toggle camera
await localParticipant.setCameraEnabled(false);
```

---

## 🔧 Common Commands

### Development
```bash
npm run dev          # Start dev server
npm run build        # Build for production
npm run start        # Run production build
```

### Deployment (Vercel)
```bash
npm i -g vercel
vercel --prod
```

### Firebase Functions
```bash
firebase deploy --only functions
firebase functions:log
```

---

## 🐛 Troubleshooting

### ❌ CORS Error
**Fix:** Add your domain to `allowedOrigins` in Firebase Functions

### ❌ Black Screen
**Fix:** Use HTTPS or localhost (required for camera/mic)

### ❌ Token Invalid
**Fix:** Verify API credentials match LiveKit server

### ❌ Connection Failed
**Fix:** Check network, firewall, and WebSocket support

---

## 📦 Required Packages

```json
{
  "dependencies": {
    "@livekit/components-react": "^2.x",
    "livekit-client": "^2.x",
    "axios": "^1.x",
    "next": "^14.x",
    "react": "^18.x"
  }
}
```

---

## 🎨 Features Included

- ✅ One-on-one calls (PIP layout)
- ✅ Group calls (grid layout)
- ✅ Mic/camera toggle
- ✅ Flip camera
- ✅ Real-time participant tracking
- ✅ Modern UI with Tailwind CSS
- ✅ Responsive design

---

## 🚀 Next Steps

1. Add screen sharing
2. Implement chat messages
3. Add recording
4. Create waiting room
5. Add analytics

---

## 📚 Full Documentation

See `VIDEO_CALL_INTEGRATION_DOCUMENTATION.md` for:
- Complete code examples
- Detailed explanations
- Security considerations
- Advanced features
- API reference

---

**Happy Coding! 🎉**
