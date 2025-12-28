# 🎯 Code Snippets Reference

Quick copy-paste code snippets for React/Next.js video call integration.

---

## 📋 Table of Contents

1. [Environment Setup](#environment-setup)
2. [Package Installation](#package-installation)
3. [Utility Functions](#utility-functions)
4. [Components](#components)
5. [Hooks](#hooks)
6. [Styling](#styling)

---

## Environment Setup

### `.env.local`
```env
NEXT_PUBLIC_LIVEKIT_URL=wss://call.wibechat.com
NEXT_PUBLIC_TOKEN_API=https://getlivekittoken-3xpiwheqja-uc.a.run.app
```

---

## Package Installation

### Install Command
```bash
npm install @livekit/components-react livekit-client axios
```

### package.json Dependencies
```json
{
  "dependencies": {
    "@livekit/components-react": "^2.0.0",
    "livekit-client": "^2.0.0",
    "axios": "^1.6.0",
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "autoprefixer": "^10.0.0",
    "postcss": "^8.0.0",
    "tailwindcss": "^3.4.0"
  }
}
```

---

## Utility Functions

### Fetch Token (`lib/livekit.js`)
```javascript
import axios from 'axios';

const LIVEKIT_URL = process.env.NEXT_PUBLIC_LIVEKIT_URL;
const TOKEN_API = process.env.NEXT_PUBLIC_TOKEN_API;

export async function fetchToken(room, name) {
  const response = await axios.get(TOKEN_API, {
    params: { room, name },
  });
  return response.data.token;
}

export { LIVEKIT_URL };
```

### Request Permissions
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

---

## Components

### Join Page (`app/join/page.js`)
```jsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { fetchToken, requestMediaPermissions } from '@/lib/livekit';

export default function JoinScreen() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [roomId, setRoomId] = useState('zartek-room');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleJoin = async (e) => {
    e.preventDefault();
    setError('');

    if (!name.trim() || !roomId.trim()) {
      setError('Name and Room ID are required');
      return;
    }

    setIsLoading(true);

    try {
      const hasPermission = await requestMediaPermissions();
      if (!hasPermission) {
        throw new Error('Camera and microphone permissions required');
      }

      const token = await fetchToken(roomId.trim(), name.trim());

      router.push(
        `/room/${encodeURIComponent(roomId)}?token=${encodeURIComponent(token)}&name=${encodeURIComponent(name)}`
      );
    } catch (err) {
      setError(err.message || 'Failed to join room');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-white via-blue-50 to-blue-100 flex items-center justify-center p-6">
      <div className="w-full max-w-md bg-white rounded-3xl shadow-2xl p-8">
        <h1 className="text-3xl font-bold text-center text-blue-900 mb-8">
          Join Room
        </h1>
        
        <form onSubmit={handleJoin} className="space-y-5">
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Enter your name..."
            disabled={isLoading}
            className="w-full px-4 py-3.5 bg-blue-50 border border-blue-100 rounded-xl focus:ring-2 focus:ring-blue-500"
          />
          
          <input
            type="text"
            value={roomId}
            onChange={(e) => setRoomId(e.target.value)}
            placeholder="Enter room ID..."
            disabled={isLoading}
            className="w-full px-4 py-3.5 bg-blue-50 border border-blue-100 rounded-xl focus:ring-2 focus:ring-blue-500"
          />
          
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm">
              {error}
            </div>
          )}
          
          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-gradient-to-r from-blue-500 to-blue-700 text-white py-4 rounded-xl font-bold"
          >
            {isLoading ? 'JOINING...' : 'JOIN NOW'}
          </button>
        </form>
      </div>
    </div>
  );
}
```

### Room Page (`app/room/[roomId]/page.js`)
```jsx
'use client';

import { useEffect } from 'react';
import { useRouter, useSearchParams, useParams } from 'next/navigation';
import { LiveKitRoom, RoomAudioRenderer } from '@livekit/components-react';
import '@livekit/components-styles';
import { LIVEKIT_URL } from '@/lib/livekit';

export default function RoomScreen() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();

  const roomId = params.roomId;
  const token = searchParams.get('token');

  useEffect(() => {
    if (!token) router.push('/join');
  }, [token, router]);

  if (!token) return <div>Loading...</div>;

  return (
    <LiveKitRoom
      video={true}
      audio={true}
      token={token}
      serverUrl={LIVEKIT_URL}
      onDisconnected={() => router.push('/join')}
      className="h-screen"
    >
      {/* Your room content here */}
      <RoomAudioRenderer />
    </LiveKitRoom>
  );
}
```

### Participant Video (`components/ParticipantVideo.jsx`)
```jsx
'use client';

import { VideoTrack } from '@livekit/components-react';

export default function ParticipantVideo({ track, isFullscreen }) {
  const participant = track.participant;
  const isVideoEnabled = track.publication?.isMuted === false;

  return (
    <div className={`relative w-full h-full bg-gray-800 ${
      isFullscreen ? '' : 'rounded-2xl border border-white/10'
    }`}>
      {isVideoEnabled ? (
        <VideoTrack trackRef={track} className="w-full h-full object-cover" />
      ) : (
        <div className="w-full h-full flex items-center justify-center">
          <div className="text-white text-center">
            <div className="text-4xl mb-2">👤</div>
            <p>{participant.isLocal ? 'You' : participant.identity}</p>
          </div>
        </div>
      )}
    </div>
  );
}
```

### Control Bar (`components/ControlBar.jsx`)
```jsx
'use client';

import { useState } from 'react';
import { useLocalParticipant } from '@livekit/components-react';

export default function ControlBar({ onEndCall }) {
  const { localParticipant } = useLocalParticipant();
  const [isMicMuted, setIsMicMuted] = useState(false);
  const [isCameraOff, setIsCameraOff] = useState(false);

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

  return (
    <div className="absolute bottom-8 left-1/2 -translate-x-1/2 z-20">
      <div className="bg-black/60 backdrop-blur-xl rounded-3xl px-6 py-4 flex items-center space-x-4">
        <button
          onClick={toggleMicrophone}
          className={`p-3 rounded-full ${
            isMicMuted ? 'bg-red-500' : 'bg-white/10'
          } text-white`}
        >
          🎤
        </button>
        
        <button
          onClick={toggleCamera}
          className={`p-3 rounded-full ${
            isCameraOff ? 'bg-red-500' : 'bg-white/10'
          } text-white`}
        >
          📹
        </button>
        
        <button
          onClick={onEndCall}
          className="p-3 rounded-full bg-red-500 text-white"
        >
          📞
        </button>
      </div>
    </div>
  );
}
```

---

## Hooks

### Use Participants
```jsx
import { useTracks } from '@livekit/components-react';
import { Track } from 'livekit-client';

function MyComponent() {
  const tracks = useTracks(
    [
      { source: Track.Source.Camera, withPlaceholder: true },
      { source: Track.Source.ScreenShare, withPlaceholder: false },
    ],
    { onlySubscribed: false }
  );

  return <div>{tracks.length} participants</div>;
}
```

### Use Local Participant
```jsx
import { useLocalParticipant } from '@livekit/components-react';

function MyComponent() {
  const { localParticipant } = useLocalParticipant();

  const toggleMic = async () => {
    const enabled = localParticipant.isMicrophoneEnabled;
    await localParticipant.setMicrophoneEnabled(!enabled);
  };

  return <button onClick={toggleMic}>Toggle Mic</button>;
}
```

### Use Room Context
```jsx
import { useMaybeRoomContext } from '@livekit/components-react';

function MyComponent() {
  const room = useMaybeRoomContext();

  if (!room) return <div>Not in a room</div>;

  return <div>Room: {room.name}</div>;
}
```

---

## Styling

### Tailwind Config (`tailwind.config.js`)
```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      animation: {
        'fade-in': 'fadeIn 0.6s ease-out',
        'shake': 'shake 0.5s ease-in-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        shake: {
          '0%, 100%': { transform: 'translateX(0)' },
          '25%': { transform: 'translateX(-10px)' },
          '75%': { transform: 'translateX(10px)' },
        },
      },
    },
  },
  plugins: [],
}
```

### Global CSS (`app/globals.css`)
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* LiveKit Component Overrides */
.lk-room-container {
  @apply bg-gray-950;
}

.lk-participant-tile {
  @apply rounded-2xl overflow-hidden border border-white/10;
}

.lk-control-bar {
  @apply bg-black/60 backdrop-blur-xl rounded-3xl;
}
```

---

## Common Patterns

### Error Handling
```jsx
try {
  const token = await fetchToken(room, name);
  // Use token...
} catch (error) {
  console.error('Error:', error);
  setError(error.message || 'Something went wrong');
}
```

### Loading State
```jsx
const [isLoading, setIsLoading] = useState(false);

const handleAction = async () => {
  setIsLoading(true);
  try {
    await someAsyncOperation();
  } finally {
    setIsLoading(false);
  }
};
```

### Permission Check
```jsx
useEffect(() => {
  const checkPermissions = async () => {
    const hasPermission = await requestMediaPermissions();
    if (!hasPermission) {
      alert('Camera and microphone access required');
    }
  };
  checkPermissions();
}, []);
```

---

## Firebase Functions

### Token Generator (`functions/index.js`)
```javascript
const functions = require("firebase-functions");
const { AccessToken } = require("livekit-server-sdk");

exports.getLivekitToken = functions.https.onRequest(async (req, res) => {
  // CORS
  const allowedOrigins = [
    "http://localhost:3000",
    "https://your-app.vercel.app",
  ];

  const origin = req.headers.origin;
  if (allowedOrigins.includes(origin)) {
    res.set("Access-Control-Allow-Origin", origin);
  }

  res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(204).send("");
  }

  const { room, name } = req.query;

  if (!room || !name) {
    return res.status(400).json({ error: "room and name are required" });
  }

  const token = new AccessToken(
    "zartek-livekit",
    "GUmgukxUVBJyJXlEQXZRMfPdMjuJLvLU",
    { identity: name }
  );

  token.addGrant({
    room,
    roomJoin: true,
    canPublish: true,
    canSubscribe: true,
  });

  const jwt = await token.toJwt();

  return res.json({ token: jwt });
});
```

---

## Deployment Scripts

### package.json Scripts
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "deploy": "vercel --prod"
  }
}
```

### Vercel Deployment
```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
vercel --prod
```

### Firebase Functions Deployment
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Deploy functions
firebase deploy --only functions

# View logs
firebase functions:log
```

---

## Testing Snippets

### Test Token Fetch
```javascript
// Run in browser console
const testToken = async () => {
  const response = await fetch(
    'https://getlivekittoken-3xpiwheqja-uc.a.run.app?room=test-room&name=TestUser'
  );
  const data = await response.json();
  console.log('Token:', data.token);
};

testToken();
```

### Test Permissions
```javascript
// Run in browser console
const testPermissions = async () => {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: true,
      audio: true,
    });
    console.log('✅ Permissions granted');
    stream.getTracks().forEach(track => track.stop());
  } catch (error) {
    console.error('❌ Permissions denied:', error);
  }
};

testPermissions();
```

---

## Quick Commands Reference

```bash
# Create new Next.js app
npx create-next-app@latest video-call-app --typescript --tailwind --app

# Install dependencies
npm install @livekit/components-react livekit-client axios

# Run development server
npm run dev

# Build for production
npm run build

# Deploy to Vercel
vercel --prod

# Deploy Firebase Functions
firebase deploy --only functions

# View Firebase logs
firebase functions:log

# Check port usage
lsof -i :3000

# Kill process on port
kill -9 $(lsof -t -i:3000)
```

---

## Environment Variables

### Development (`.env.local`)
```env
NEXT_PUBLIC_LIVEKIT_URL=wss://call.wibechat.com
NEXT_PUBLIC_TOKEN_API=https://getlivekittoken-3xpiwheqja-uc.a.run.app
```

### Production (Vercel Dashboard)
```
NEXT_PUBLIC_LIVEKIT_URL=wss://call.wibechat.com
NEXT_PUBLIC_TOKEN_API=https://getlivekittoken-3xpiwheqja-uc.a.run.app
```

---

## Common Tailwind Classes

### Layouts
```css
/* Center everything */
min-h-screen flex items-center justify-center

/* Grid for participants */
grid grid-cols-2 gap-4

/* Full screen */
absolute inset-0 w-full h-full
```

### Buttons
```css
/* Primary button */
bg-gradient-to-r from-blue-500 to-blue-700 text-white py-4 px-6 rounded-xl font-bold

/* Icon button */
p-3 rounded-full bg-white/10 hover:bg-white/20 transition-all

/* Danger button */
bg-red-500 hover:bg-red-600 text-white p-3 rounded-full
```

### Cards
```css
/* Glass effect */
bg-black/60 backdrop-blur-xl rounded-3xl border border-white/10

/* White card */
bg-white rounded-3xl shadow-2xl p-8

/* Video tile */
rounded-2xl overflow-hidden border border-white/10
```

---

**Last Updated:** December 23, 2025  
**Use Case:** Quick copy-paste reference for video call integration
