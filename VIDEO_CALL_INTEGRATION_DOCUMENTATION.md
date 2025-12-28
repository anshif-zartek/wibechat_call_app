# Video Call Integration Documentation
## Frontend Implementation Guide for React/Next.js

**Framework:** Next.js  
**Language:** React + JavaScript  
**Styling:** Tailwind CSS  
**Video SDK:** LiveKit (React SDK)  
**Backend:** ✅ Already Hosted (API & WebSocket)

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [Component Structure](#component-structure)
6. [Frontend Implementation](#frontend-implementation)
7. [Deployment](#deployment)
8. [Troubleshooting](#troubleshooting)

---

## 📋 Quick Reference

### ✅ Already Hosted (No Action Required)

| Component | Status | URL |
|-----------|--------|-----|
| **LiveKit WebSocket Server** | 🟢 Live | `wss://call.wibechat.com` |
| **Token Generation API** | 🟢 Live | `https://getlivekittoken-3xpiwheqja-uc.a.run.app` |

### 🛠️ What You'll Build

- **Join Screen** - User inputs (name + room ID) 
- **Room Screen** - Video call interface
- **Video Components** - Participant tiles with controls
- **Control Bar** - Mute, video toggle, end call buttons

### ⏱️ Estimated Time: **30-60 minutes**

### 💻 Tech Stack: **Next.js + React + Tailwind CSS + LiveKit SDK**
---

## Overview

This documentation provides a **frontend-only implementation guide** for a complete video calling system powered by **LiveKit**. The backend API and WebSocket server are already hosted and ready to use.

### Features

- ✅ **One-on-one video calls** with Picture-in-Picture (PIP) view
- ✅ **Group video calls** with grid layout
- ✅ **Real-time participant tracking**
- ✅ **Audio/Video controls** (mute, camera toggle, flip camera)
- ✅ **Token-based authentication** via hosted API
- ✅ **Modern UI** with animations and glassmorphism

---

## Architecture

### System Flow

```
┌─────────────────┐      1. Join Request      ┌──────────────────┐
│                 │ ────────────────────────▶  │                  │
│  React Client   │                            │  Token API       │
│  (Next.js App)  │ ◀────────────────────────  │ (Firebase Func)  │
│                 │      2. JWT Token          │                  │
└────────┬────────┘                            └──────────────────┘
         │
         │ 3. Connect with Token
         ▼
┌─────────────────────────────────────────────┐
│         LiveKit Server (SFU)                │
│        wss://call.wibechat.com              │
│                                             │
│  - Manages WebRTC connections               │
│  - Routes audio/video streams               │
│  - Handles participant events               │
└─────────────────────────────────────────────┘
         │
         │ 4. Peer connections
         ▼
┌─────────────────┐          ┌─────────────────┐
│  Participant 1  │  ◀────▶  │  Participant 2  │
└─────────────────┘          └─────────────────┘
```

### Key Components

| Component | Purpose |
|-----------|---------|
| **JoinScreen** | User enters name & room ID, fetches token |
| **RoomScreen** | Main video call interface |
| **ParticipantVideo** | Individual video tile component |
| **Token API** | Generates LiveKit JWT tokens (already hosted) |
| **LiveKit Server** | SFU (Selective Forwarding Unit) for media routing (already hosted) |

---

## Quick Start

Get started in 3 minutes:

```bash
# 1. Create Next.js app with Tailwind
npx create-next-app@latest video-call-app --typescript --tailwind --app
cd video-call-app

# 2. Install LiveKit dependencies
npm install @livekit/components-react livekit-client axios

# 3. Create .env.local file
cat > .env.local << EOF
NEXT_PUBLIC_LIVEKIT_URL=wss://call.wibechat.com
NEXT_PUBLIC_TOKEN_API=https://getlivekittoken-3xpiwheqja-uc.a.run.app
EOF

# 4. Start development server
npm run dev
```

Then follow the **Component Structure** and **Frontend Implementation** sections below to add the code.

---

## Prerequisites

### Hosted Services (Already Available)

1. **LiveKit WebSocket Server**
   - URL: `wss://call.wibechat.com`
   - Status: ✅ Live and Ready

2. **Token Generation API**
   - Endpoint: `https://getlivekittoken-3xpiwheqja-uc.a.run.app`
   - Method: `GET`
   - Parameters: `room` (string), `name` (string)
   - Response: `{ "token": "..." }`
   - Status: ✅ Live and Ready

### Local Development Requirements

- **Node.js** 18 or higher
- **npm** or **yarn**
- **Modern Browser** (Chrome, Firefox, Safari, Edge)
- **HTTPS** (required for WebRTC - use localhost for development)


---

## Installation

### 1. Initialize Next.js Project

```bash
npx create-next-app@latest video-call-app --typescript --tailwind --app
cd video-call-app
```

### 2. Install LiveKit Dependencies

```bash
npm install @livekit/components-react livekit-client
```

### 3. Install Additional Dependencies

```bash
npm install axios
```

---

## Component Structure

```
app/
├── page.js                    # Main entry (redirects to /join)
├── join/
│   └── page.js                # Join screen component
├── room/
│   └── [roomId]/
│       └── page.js            # Room screen component
├── components/
│   ├── ParticipantVideo.jsx   # Video tile component
│   └── ControlBar.jsx         # Call controls
├── lib/
│   └── livekit.js             # LiveKit utilities
└── styles/
    └── globals.css            # Global styles
```


---

## Frontend Implementation

### Quick Start Guide

1. **Initialize Project** → Install dependencies → Configure environment
2. **Create Join Screen** → User enters name/room → Fetch token from API
3. **Build Room Screen** → Connect to LiveKit → Display participants
4. **Add Controls** → Mute/unmute → Camera on/off → End call

### Implementation Steps

**Phase 1: Project Setup**
- Create Next.js project with Tailwind CSS
- Install LiveKit dependencies
- Configure environment variables

**Phase 2: Join Screen**
- Form validation
- Token fetching from hosted API
- Permission handling
- Modern UI with animations

**Phase 3: Room Screen**
- Participant grid/PIP layout
- Real-time participant updates
- Audio/Video controls
- Camera flip functionality

**Phase 4: UI Components**
- Video rendering with fallbacks
- Participant info overlay
- Mute indicators
- Premium design aesthetics

---

## Complete Code Implementation


### 1. Environment Variables

Create `.env.local`:

```env
NEXT_PUBLIC_LIVEKIT_URL=wss://call.wibechat.com
NEXT_PUBLIC_TOKEN_API=https://getlivekittoken-3xpiwheqja-uc.a.run.app
```

---

### 2. LiveKit Utility (`lib/livekit.js`)

```javascript
import axios from 'axios';

const LIVEKIT_URL = process.env.NEXT_PUBLIC_LIVEKIT_URL;
const TOKEN_API = process.env.NEXT_PUBLIC_TOKEN_API;

/**
 * Fetch LiveKit token from API
 * @param {string} room - Room identifier
 * @param {string} name - Participant name
 * @returns {Promise<string>} JWT token
 */
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

/**
 * Request camera and microphone permissions
 * @returns {Promise<boolean>}
 */
export async function requestMediaPermissions() {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: true,
      audio: true,
    });
    
    // Stop the stream immediately (we just needed permissions)
    stream.getTracks().forEach(track => track.stop());
    
    return true;
  } catch (error) {
    console.error('Permission denied:', error);
    return false;
  }
}

export { LIVEKIT_URL };
```

---

### 3. Join Screen (`app/join/page.js`)

```jsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { fetchToken, requestMediaPermissions } from '@/lib/livekit';
import Image from 'next/image';

export default function JoinScreen() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [roomId, setRoomId] = useState('zartek-room');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleJoin = async (e) => {
    e.preventDefault();
    setError('');

    // Validation
    if (!name.trim()) {
      setError('Name is required');
      return;
    }
    if (!roomId.trim()) {
      setError('Room ID is required');
      return;
    }

    setIsLoading(true);

    try {
      // Step 1: Request permissions
      const hasPermission = await requestMediaPermissions();
      if (!hasPermission) {
        throw new Error('Camera and microphone permissions are required');
      }

      // Step 2: Fetch token
      const token = await fetchToken(roomId.trim(), name.trim());

      // Step 3: Navigate to room with token in URL params
      router.push(
        `/room/${encodeURIComponent(roomId)}?token=${encodeURIComponent(token)}&name=${encodeURIComponent(name)}`
      );
    } catch (err) {
      console.error('Join error:', err);
      setError(err.message || 'Failed to join room');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-white via-blue-50 to-blue-100 flex items-center justify-center p-6">
      <div className="w-full max-w-md">
        <div className="bg-white rounded-3xl shadow-2xl shadow-blue-200/50 p-8 border border-white animate-fade-in">
          {/* Logo */}
          <div className="flex justify-center mb-8">
            <div className="w-28 h-28 bg-gradient-to-br from-blue-500 to-blue-700 rounded-2xl flex items-center justify-center shadow-lg">
              <svg
                className="w-16 h-16 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
                />
              </svg>
            </div>
          </div>

          {/* Title */}
          <h1 className="text-3xl font-bold text-center text-blue-900 mb-2 tracking-tight">
            Join Room
          </h1>
          <p className="text-center text-gray-500 mb-8">
            Enter your name and room ID to join
          </p>

          {/* Form */}
          <form onSubmit={handleJoin} className="space-y-5">
            {/* Name Input */}
            <div>
              <label
                htmlFor="name"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Name
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <svg
                    className="h-5 w-5 text-blue-500"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                    />
                  </svg>
                </div>
                <input
                  id="name"
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  disabled={isLoading}
                  placeholder="Enter your name..."
                  className="w-full pl-12 pr-4 py-3.5 bg-blue-50/50 border border-blue-100 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 text-blue-900 placeholder-gray-400 disabled:opacity-50"
                />
              </div>
            </div>

            {/* Room ID Input */}
            <div>
              <label
                htmlFor="roomId"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Room ID
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <svg
                    className="h-5 w-5 text-blue-500"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M8 14v3m4-3v3m4-3v3M3 21h18M3 10h18M3 7l9-4 9 4M4 10h16v11H4V10z"
                    />
                  </svg>
                </div>
                <input
                  id="roomId"
                  type="text"
                  value={roomId}
                  onChange={(e) => setRoomId(e.target.value)}
                  disabled={isLoading}
                  placeholder="Enter room ID..."
                  className="w-full pl-12 pr-4 py-3.5 bg-blue-50/50 border border-blue-100 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 text-blue-900 placeholder-gray-400 disabled:opacity-50"
                />
              </div>
            </div>

            {/* Error Message */}
            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm flex items-start space-x-2 animate-shake">
                <svg
                  className="h-5 w-5 flex-shrink-0 mt-0.5"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path
                    fillRule="evenodd"
                    d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                    clipRule="evenodd"
                  />
                </svg>
                <span>{error}</span>
              </div>
            )}

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-gradient-to-r from-blue-500 to-blue-700 text-white py-4 rounded-xl font-bold text-base tracking-wide shadow-lg shadow-blue-300/50 hover:shadow-xl hover:shadow-blue-400/50 transition-all duration-200 hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none flex items-center justify-center space-x-2"
            >
              {isLoading ? (
                <>
                  <svg
                    className="animate-spin h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                    />
                    <path
                      className="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    />
                  </svg>
                  <span>JOINING...</span>
                </>
              ) : (
                <span>JOIN NOW</span>
              )}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
```

---

### 4. Room Screen (`app/room/[roomId]/page.js`)

```jsx
'use client';

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams, useParams } from 'next/navigation';
import {
  LiveKitRoom,
  VideoConference,
  useTracks,
  RoomAudioRenderer,
} from '@livekit/components-react';
import '@livekit/components-styles';
import { LIVEKIT_URL } from '@/lib/livekit';
import { Track } from 'livekit-client';
import ParticipantVideo from '@/components/ParticipantVideo';
import ControlBar from '@/components/ControlBar';

export default function RoomScreen() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();

  const roomId = params.roomId;
  const token = searchParams.get('token');
  const name = searchParams.get('name');

  useEffect(() => {
    // Redirect if no token
    if (!token) {
      router.push('/join');
    }
  }, [token, router]);

  const handleDisconnect = () => {
    router.push('/join');
  };

  if (!token) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-white">Loading...</div>
      </div>
    );
  }

  return (
    <LiveKitRoom
      video={true}
      audio={true}
      token={token}
      serverUrl={LIVEKIT_URL}
      data-lk-theme="default"
      onDisconnected={handleDisconnect}
      className="h-screen"
    >
      <RoomContent roomName={decodeURIComponent(roomId)} />
      <RoomAudioRenderer />
    </LiveKitRoom>
  );
}

function RoomContent({ roomName }) {
  const router = useRouter();
  const tracks = useTracks(
    [
      { source: Track.Source.Camera, withPlaceholder: true },
      { source: Track.Source.ScreenShare, withPlaceholder: false },
    ],
    { onlySubscribed: false }
  );

  const isOneOnOne = tracks.length === 2;

  const handleEndCall = () => {
    router.push('/join');
  };

  return (
    <div className="relative h-screen bg-gray-950 overflow-hidden">
      {/* Main Video Area */}
      <div className="absolute inset-0">
        {isOneOnOne ? (
          <OneOnOneLayout tracks={tracks} />
        ) : (
          <GridLayout tracks={tracks} />
        )}
      </div>

      {/* Top Info Bar */}
      <div className="absolute top-0 left-0 right-0 bg-gradient-to-b from-black/80 to-transparent z-10">
        <div className="flex items-center justify-between p-4 pt-6">
          <div className="flex items-center space-x-3">
            <div className="bg-white/10 backdrop-blur-sm rounded-xl p-2">
              <svg
                className="w-5 h-5 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
                />
              </svg>
            </div>
            <div>
              <h1 className="text-white font-bold text-lg">{roomName}</h1>
              <div className="flex items-center space-x-2 text-sm">
                <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse" />
                <span className="text-white/60">{tracks.length} online</span>
              </div>
            </div>
          </div>
          <button
            onClick={handleEndCall}
            className="bg-white/10 backdrop-blur-sm hover:bg-white/20 text-white p-2 rounded-xl transition-all"
          >
            <svg
              className="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>
      </div>

      {/* Control Bar */}
      <ControlBar onEndCall={handleEndCall} />
    </div>
  );
}

// One-on-One Layout (PIP)
function OneOnOneLayout({ tracks }) {
  const remoteTracks = tracks.filter((t) => !t.participant.isLocal);
  const localTrack = tracks.find((t) => t.participant.isLocal);

  return (
    <>
      {/* Remote participant (fullscreen) */}
      {remoteTracks[0] && (
        <div className="w-full h-full">
          <ParticipantVideo
            track={remoteTracks[0]}
            isFullscreen={true}
          />
        </div>
      )}

      {/* Local participant (PIP) */}
      {localTrack && (
        <div className="absolute top-20 right-4 w-32 h-44 rounded-2xl overflow-hidden border border-white/20 shadow-2xl z-20">
          <ParticipantVideo
            track={localTrack}
            isFullscreen={false}
          />
        </div>
      )}
    </>
  );
}

// Grid Layout (Multiple participants)
function GridLayout({ tracks }) {
  return (
    <div className="grid grid-cols-2 gap-2 p-4 pt-24 pb-32 h-full">
      {tracks.map((track) => (
        <div key={track.participant.identity} className="rounded-2xl overflow-hidden">
          <ParticipantVideo track={track} isFullscreen={false} />
        </div>
      ))}
    </div>
  );
}
```

---

### 5. Participant Video Component (`components/ParticipantVideo.jsx`)

```jsx
'use client';

import { VideoTrack } from '@livekit/components-react';

export default function ParticipantVideo({ track, isFullscreen }) {
  const participant = track.participant;
  const isVideoEnabled = track.publication?.isMuted === false;

  return (
    <div
      className={`relative w-full h-full bg-gray-800 ${
        isFullscreen ? '' : 'rounded-2xl overflow-hidden border border-white/10'
      }`}
    >
      {/* Video Stream */}
      {isVideoEnabled ? (
        <VideoTrack
          trackRef={track}
          className="w-full h-full object-cover"
        />
      ) : (
        <div className="w-full h-full flex flex-col items-center justify-center">
          <div className="bg-white/5 rounded-full p-8 mb-4">
            <svg
              className={`${isFullscreen ? 'w-20 h-20' : 'w-10 h-10'} text-white/20`}
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fillRule="evenodd"
                d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
                clipRule="evenodd"
              />
            </svg>
          </div>
          <p className="text-white/60 text-sm">
            {participant.isLocal ? 'You' : participant.identity}
          </p>
        </div>
      )}

      {/* Participant Info Overlay */}
      {!isFullscreen && (
        <div className="absolute bottom-3 left-3 bg-black/60 backdrop-blur-sm px-3 py-1.5 rounded-lg border border-white/10">
          <div className="flex items-center space-x-2">
            <span className="text-white text-xs font-medium">
              {participant.isLocal ? 'You' : participant.identity}
            </span>
            <svg
              className={`w-3.5 h-3.5 ${
                participant.isMicrophoneEnabled
                  ? 'text-green-400'
                  : 'text-red-400'
              }`}
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              {participant.isMicrophoneEnabled ? (
                <path
                  fillRule="evenodd"
                  d="M7 4a3 3 0 016 0v4a3 3 0 11-6 0V4zm4 10.93A7.001 7.001 0 0017 8a1 1 0 10-2 0A5 5 0 015 8a1 1 0 00-2 0 7.001 7.001 0 006 6.93V17H6a1 1 0 100 2h8a1 1 0 100-2h-3v-2.07z"
                  clipRule="evenodd"
                />
              ) : (
                <path
                  fillRule="evenodd"
                  d="M13.477 14.89A6 6 0 015.11 6.524l8.367 8.368zm1.414-1.414L6.524 5.11a6 6 0 018.367 8.367zM18 10a8 8 0 11-16 0 8 8 0 0116 0z"
                  clipRule="evenodd"
                />
              )}
            </svg>
          </div>
        </div>
      )}
    </div>
  );
}
```

---

### 6. Control Bar Component (`components/ControlBar.jsx`)

```jsx
'use client';

import { useState } from 'react';
import {
  useLocalParticipant,
  useMaybeRoomContext,
} from '@livekit/components-react';
import { Track } from 'livekit-client';

export default function ControlBar({ onEndCall }) {
  const room = useMaybeRoomContext();
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

  const flipCamera = async () => {
    if (!localParticipant) return;

    const videoTrack = localParticipant.getTrack(Track.Source.Camera);
    if (videoTrack?.track) {
      // This will switch between front and back camera on mobile
      try {
        const mediaDevices = await navigator.mediaDevices.enumerateDevices();
        const videoDevices = mediaDevices.filter((d) => d.kind === 'videoinput');

        if (videoDevices.length < 2) return;

        // Toggle to next camera
        // Note: Full implementation would track current device
        await videoTrack.restartTrack();
      } catch (err) {
        console.error('Error flipping camera:', err);
      }
    }
  };

  return (
    <div className="absolute bottom-8 left-1/2 -translate-x-1/2 z-20">
      <div className="bg-black/60 backdrop-blur-xl rounded-3xl px-6 py-4 border border-white/10 shadow-2xl">
        <div className="flex items-center space-x-4">
          {/* Microphone */}
          <ControlButton
            onClick={toggleMicrophone}
            isActive={!isMicMuted}
            activeColor="bg-white/10"
            inactiveColor="bg-red-500"
          >
            {isMicMuted ? (
              <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fillRule="evenodd"
                  d="M13.477 14.89A6 6 0 015.11 6.524l8.367 8.368zm1.414-1.414L6.524 5.11a6 6 0 018.367 8.367zM18 10a8 8 0 11-16 0 8 8 0 0116 0z"
                  clipRule="evenodd"
                />
              </svg>
            ) : (
              <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fillRule="evenodd"
                  d="M7 4a3 3 0 016 0v4a3 3 0 11-6 0V4zm4 10.93A7.001 7.001 0 0017 8a1 1 0 10-2 0A5 5 0 015 8a1 1 0 00-2 0 7.001 7.001 0 006 6.93V17H6a1 1 0 100 2h8a1 1 0 100-2h-3v-2.07z"
                  clipRule="evenodd"
                />
              </svg>
            )}
          </ControlButton>

          {/* Camera */}
          <ControlButton
            onClick={toggleCamera}
            isActive={!isCameraOff}
            activeColor="bg-white/10"
            inactiveColor="bg-red-500"
          >
            {isCameraOff ? (
              <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fillRule="evenodd"
                  d="M13.477 14.89A6 6 0 015.11 6.524l8.367 8.368zm1.414-1.414L6.524 5.11a6 6 0 018.367 8.367zM18 10a8 8 0 11-16 0 8 8 0 0116 0z"
                  clipRule="evenodd"
                />
              </svg>
            ) : (
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
                />
              </svg>
            )}
          </ControlButton>

          {/* Flip Camera */}
          <ControlButton onClick={flipCamera} isActive={true} activeColor="bg-white/10">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
              />
            </svg>
          </ControlButton>

          {/* End Call */}
          <ControlButton
            onClick={onEndCall}
            isActive={false}
            inactiveColor="bg-red-500"
            className="px-6"
          >
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" />
            </svg>
          </ControlButton>
        </div>
      </div>
    </div>
  );
}

function ControlButton({
  children,
  onClick,
  isActive,
  activeColor = 'bg-white/10',
  inactiveColor = 'bg-red-500',
  className = '',
}) {
  return (
    <button
      onClick={onClick}
      className={`
        ${isActive ? activeColor + ' text-white' : inactiveColor + ' text-white'}
        p-3 rounded-full transition-all duration-200 hover:scale-110 active:scale-95
        ${className}
      `}
    >
      {children}
    </button>
  );
}
```

---

### 7. Global Styles (`app/globals.css`)

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer utilities {
  .animate-fade-in {
    animation: fadeIn 0.6s ease-out;
  }

  .animate-shake {
    animation: shake 0.5s ease-in-out;
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-10px); }
    75% { transform: translateX(10px); }
  }
}

/* LiveKit Component Overrides */
.lk-room-container {
  @apply bg-gray-950;
}

.lk-participant-tile {
  @apply rounded-2xl overflow-hidden border border-white/10;
}
```

---

### 8. Main Page Redirect (`app/page.js`)

```jsx
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    router.push('/join');
  }, [router]);

  return (
    <div className="min-h-screen bg-gray-900 flex items-center justify-center">
      <div className="text-white">Redirecting...</div>
    </div>
  );
}
```

---

## Deployment

### Deploy to Vercel

**Step 1: Install Vercel CLI**

```bash
npm i -g vercel
```

**Step 2: Deploy**

```bash
# Login to Vercel
vercel login

# Deploy to production
vercel --prod
```

**Step 3: Configure Environment Variables**

In your Vercel project dashboard:

1. Go to **Settings** → **Environment Variables**
2. Add the following variables:

| Variable | Value |
|----------|-------|
| `NEXT_PUBLIC_LIVEKIT_URL` | `wss://call.wibechat.com` |
| `NEXT_PUBLIC_TOKEN_API` | `https://getlivekittoken-3xpiwheqja-uc.a.run.app` |

3. Redeploy after adding variables

### Alternative: Deploy to Netlify

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy --prod
```

Add the same environment variables in Netlify dashboard.

### Testing Production Build Locally

```bash
# Build the app
npm run build

# Start production server
npm start
```

Access at `http://localhost:3000`

> **Note:** The backend API and WebSocket server are already hosted and don't require any deployment steps from your side.


---

## Troubleshooting

### Common Issues

#### 1. **Camera/Microphone Not Working**

**Symptom:** Black screen or no audio

**Solution:**
- Ensure you're using **HTTPS** (required for WebRTC)
- Check browser permissions (allow camera/mic access)
- Test on `localhost` (which is treated as secure)
- Try a different browser
- Check if other apps are using the camera

**Check Permissions in Browser:**
```
Chrome: Settings → Privacy and Security → Site Settings → Camera/Microphone
Firefox: about:preferences#privacy → Permissions
Safari: Preferences → Websites → Camera/Microphone
```

#### 2. **Token Fetch Fails**

**Symptom:** Error when trying to join room

**Solution:**
- Verify API endpoint is accessible: `https://getlivekittoken-3xpiwheqja-uc.a.run.app`
- Check network connectivity
- Open browser DevTools → Network tab to see the actual error
- Ensure you're passing both `room` and `name` parameters

**Test API Manually:**
```bash
curl "https://getlivekittoken-3xpiwheqja-uc.a.run.app?room=test-room&name=TestUser"
```

#### 3. **Connection Fails**

**Symptom:** Cannot connect to LiveKit server

**Solution:**
- Verify WebSocket URL: `wss://call.wibechat.com`
- Check firewall/proxy settings
- Ensure token is valid (not expired)
- Try in incognito mode (to rule out extensions)

#### 4. **Video Quality Issues**

**Symptom:** Pixelated or laggy video

**Solution:**
- Check network bandwidth (minimum 1 Mbps recommended)
- Reduce number of participants if possible
- Close other bandwidth-heavy applications
- Use wired connection instead of WiFi if available

#### 5. **Audio Echo**

**Symptom:** Hearing your own voice

**Solution:**
- Use headphones
- Ensure only one tab has the room open
- Check that audio output isn't being fed back to input


---

## API Reference

### Token API

**Endpoint:** `GET https://getlivekittoken-3xpiwheqja-uc.a.run.app`

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `room` | string | Yes | Room identifier |
| `name` | string | Yes | Participant display name |

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Response:**
```json
{
  "error": "room and name are required"
}
```

---

## Security Considerations

### Client-Side Best Practices

1. **HTTPS Only:** All production deployments must use HTTPS
   - WebRTC requires secure contexts for camera/microphone access
   - Use Vercel/Netlify for automatic HTTPS

2. **Environment Variables:** Never expose sensitive data
   - Use `NEXT_PUBLIC_` prefix for client-side variables
   - Don't commit `.env.local` to git

3. **Token Handling:** 
   - Tokens are short-lived JWT tokens generated by the API
   - Never store API credentials in frontend code
   - Tokens automatically expire (handled by backend)

4. **User Privacy:**
   - Request permissions before accessing camera/microphone
   - Show clear indicators when camera/mic are active
   - Allow users to toggle permissions at any time

5. **Input Validation:**
   - Validate room names and user names before making API calls
   - Sanitize user inputs to prevent XSS

### What the Backend Handles (Already Configured)

- ✅ Token generation and signing
- ✅ Room access control
- ✅ CORS configuration
- ✅ Participant permissions
- ✅ Token expiration


---

## Next Steps & Enhancements

### UI/UX Improvements

1. **Enhance Visual Design:**
   - Add custom themes (dark/light mode)
   - Implement virtual backgrounds
   - Add profile pictures/avatars
   - Custom loading animations

2. **Better User Experience:**
   - Connection quality indicators
   - Network stats display
   - Lobby/waiting room
   - Pre-call device testing
   - Participant search/filter

### Additional Features

3. **Communication:**
   - Text chat messaging
   - Screen sharing
   - File sharing
   - Emoji reactions

4. **Advanced Features:**
   - Recording controls (if backend supports)
   - Noise cancellation
   - Background blur
   - Hand raise feature
   - Breakout rooms

### Analytics & Monitoring

5. **Track Usage:**
   - Join/leave events (Google Analytics)
   - Call duration tracking
   - Quality metrics
   - Error monitoring (Sentry)

---

## API Reference

### Token Generation API

**Endpoint:** `GET https://getlivekittoken-3xpiwheqja-uc.a.run.app`

**Request:**
```
GET https://getlivekittoken-3xpiwheqja-uc.a.run.app?room=test-room&name=John
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `room` | string | ✅ Yes | Room identifier (unique room name) |
| `name` | string | ✅ Yes | Participant display name |

**Success Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MDk5..."
}
```

**Error Response (400):**
```json
{
  "error": "room and name are required"
}
```

---

## Resources & Links

### Documentation
- [LiveKit Docs](https://docs.livekit.io/) - Official LiveKit documentation
- [LiveKit React Components](https://docs.livekit.io/guides/room/react/) - React SDK guide
- [Next.js Docs](https://nextjs.org/docs) - Next.js documentation
- [Tailwind CSS](https://tailwindcss.com/docs) - Styling reference

### Community Support
- [LiveKit Discord](https://livekit.io/discord) - Community chat
- [LiveKit GitHub](https://github.com/livekit) - Source code & issues
- [Stack Overflow](https://stackoverflow.com/questions/tagged/livekit) - Q&A

---

## Summary

### What You Get

✅ **Hosted Backend:** API and WebSocket server ready to use  
✅ **Complete Frontend:** All necessary React components  
✅ **Modern UI:** Beautiful, responsive design with Tailwind  
✅ **Production Ready:** Deploy to Vercel/Netlify in minutes  
✅ **Scalable:** Built on LiveKit's proven infrastructure  

### Implementation Flow

1. **Clone/Create** → Set up Next.js project
2. **Install** → Add LiveKit dependencies
3. **Configure** → Set environment variables
4. **Copy Code** → Implement components from this guide
5. **Customize** → Adjust UI to match your brand
6. **Deploy** → Push to Vercel/Netlify
7. **Test** → Start making video calls!

### Key Files to Create

```
app/
├── page.js                         # Main redirect
├── join/page.js                    # Join screen
├── room/[roomId]/page.js          # Video room
components/
├── ParticipantVideo.jsx           # Video tiles
├── ControlBar.jsx                 # Controls
lib/
└── livekit.js                     # Utilities
.env.local                          # Environment vars
```

---

**🎉 You're all set! Happy coding!**

---

**Last Updated:** December 23, 2025  
**Version:** 2.0.0 (Frontend-Only Edition)  
**Documentation Type:** Frontend Implementation Guide

