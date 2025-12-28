# 📹 Video Call Integration Documentation

> Complete guide for integrating LiveKit video calls into React/Next.js websites

---

## 📚 Documentation Files

This repository contains comprehensive documentation for integrating your Flutter-based video call system into a React/Next.js website. The documentation is split into three files for easy navigation:

### 1. 🚀 [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)
**Perfect for:** Getting started quickly  
**Time needed:** 5-10 minutes

Quick setup guide with:
- Installation commands
- File structure overview
- Essential code snippets
- Common troubleshooting

### 2. 📖 [VIDEO_CALL_INTEGRATION_DOCUMENTATION.md](./VIDEO_CALL_INTEGRATION_DOCUMENTATION.md)
**Perfect for:** Complete implementation  
**Time needed:** 30-60 minutes

Comprehensive guide with:
- Full architecture explanation
- Complete code examples for all components
- API reference
- Security considerations
- Deployment instructions
- Advanced features

### 3. 🔄 [FLUTTER_TO_REACT_COMPARISON.md](./FLUTTER_TO_REACT_COMPARISON.md)
**Perfect for:** Understanding differences  
**Time needed:** 15-20 minutes

Side-by-side comparison with:
- Flutter vs React code examples
- Technology mapping
- Feature parity matrix
- Migration checklist
- Best practices for each platform

---

## 🎯 Quick Overview

### What This Does

This documentation helps you create a **fully-functional video calling website** using:
- **Next.js** (React framework)
- **LiveKit** (Video SDK)
- **Tailwind CSS** (Styling)
- **Firebase Functions** (Token API)

### Features Included

✅ One-on-one video calls with Picture-in-Picture  
✅ Group video calls with grid layout  
✅ Real-time participant tracking  
✅ Microphone and camera controls  
✅ Camera flip functionality  
✅ Modern, responsive UI  
✅ Token-based authentication  

---

## 🏗️ Architecture

```
┌─────────────────┐     Fetch Token     ┌──────────────────┐
│                 │ ──────────────────▶  │                  │
│  React Client   │                      │  Token API       │
│  (Next.js App)  │ ◀──────────────────  │ (Firebase Func)  │
│                 │    Return JWT        │                  │
└────────┬────────┘                      └──────────────────┘
         │
         │ Connect with Token
         ▼
┌──────────────────────────────┐
│   LiveKit SFU Server         │
│   wss://call.wibechat.com    │
└──────────────────────────────┘
         │
         │ WebRTC Streams
         ▼
┌─────────────────┐          ┌─────────────────┐
│  Participant 1  │  ◀────▶  │  Participant 2  │
└─────────────────┘          └─────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites

- Node.js 18+
- Next.js project (or create new one)
- Firebase account (for token API)
- LiveKit server access

### Quick Start (5 minutes)

1. **Install dependencies:**
   ```bash
   npm install @livekit/components-react livekit-client axios
   ```

2. **Create environment file** (`.env.local`):
   ```env
   NEXT_PUBLIC_LIVEKIT_URL=wss://call.wibechat.com
   NEXT_PUBLIC_TOKEN_API=https://getlivekittoken-3xpiwheqja-uc.a.run.app
   ```

3. **Copy code from documentation:**
   - Join screen component
   - Room screen component
   - Participant video component
   - Control bar component

4. **Run development server:**
   ```bash
   npm run dev
   ```

5. **Open browser:**
   ```
   http://localhost:3000
   ```

**📖 For detailed steps, see [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)**

---

## 📂 Project Structure

```
your-nextjs-app/
├── app/
│   ├── page.js                    # Homepage (redirects to /join)
│   ├── join/
│   │   └── page.js                # Join screen
│   ├── room/
│   │   └── [roomId]/
│   │       └── page.js            # Video room
│   └── globals.css                # Global styles
├── components/
│   ├── ParticipantVideo.jsx       # Video tile component
│   └── ControlBar.jsx             # Call controls
├── lib/
│   └── livekit.js                 # LiveKit utilities
├── .env.local                     # Environment variables
└── package.json
```

---

## 🔑 API Configuration

### Your Token API

**Endpoint:** `https://getlivekittoken-3xpiwheqja-uc.a.run.app`

**Parameters:**
- `room` - Room identifier
- `name` - Participant name

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### LiveKit Server

**WebSocket URL:** `wss://call.wibechat.com`

**Credentials:**
- API Key: `zartek-livekit`
- API Secret: `GUmgukxUVBJyJXlEQXZRMfPdMjuJLvLU`

---

## 🎨 UI Preview

### Join Screen
- Clean, modern form
- Name and room ID inputs
- Gradient background
- Smooth animations
- Error handling

### Video Room
- Fullscreen video for 1-on-1 calls
- Grid layout for group calls
- Floating PIP for local video
- Bottom control bar with glass effect
- Top info bar showing participant count

### Controls
- 🎤 Microphone toggle
- 📹 Camera toggle
- 🔄 Flip camera
- 📞 End call button

---

## 🔧 Technologies Used

| Category | Technology |
|----------|-----------|
| Framework | Next.js 14+ |
| Language | React + JavaScript |
| Styling | Tailwind CSS |
| Video SDK | LiveKit React Components |
| HTTP Client | Axios |
| Backend | Firebase Cloud Functions |
| Media Server | LiveKit SFU |

---

## 📱 Supported Features

### Core Features
- [x] Video calls (1-on-1 and group)
- [x] Audio calls
- [x] Screen sharing (can be added)
- [x] Camera switching
- [x] Mic/camera mute
- [x] Real-time participant updates

### UI Features
- [x] Responsive design
- [x] Dark theme
- [x] Animations
- [x] Loading states
- [x] Error handling
- [x] Permission requests

### Advanced Features
- [x] Simulcast (bandwidth optimization)
- [x] Adaptive streaming
- [x] Dynacast
- [ ] Recording (can be added)
- [ ] Chat messages (can be added)
- [ ] Virtual backgrounds (can be added)

---

## 🐛 Troubleshooting

### Common Issues

1. **CORS Error**
   - Add your domain to Firebase Functions allowed origins
   - Redeploy functions

2. **Camera not working**
   - Use HTTPS or localhost
   - Check browser permissions
   - Ensure WebRTC support

3. **Connection failed**
   - Verify token API is accessible
   - Check LiveKit server URL
   - Verify credentials

4. **Black screen**
   - Check camera permissions
   - Verify video track is enabled
   - Check browser console for errors

**📖 For detailed troubleshooting, see [VIDEO_CALL_INTEGRATION_DOCUMENTATION.md](./VIDEO_CALL_INTEGRATION_DOCUMENTATION.md#troubleshooting)**

---

## 📦 Installation Guide

### Option 1: New Project

```bash
# Create Next.js app
npx create-next-app@latest video-call-app --typescript --tailwind --app

# Navigate to project
cd video-call-app

# Install LiveKit
npm install @livekit/components-react livekit-client axios

# Copy code from documentation
# Run dev server
npm run dev
```

### Option 2: Existing Project

```bash
# Install LiveKit
npm install @livekit/components-react livekit-client axios

# Create components (see documentation)
# Add routes (see documentation)
# Configure environment variables
```

---

## 🚀 Deployment

### Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod

# Add environment variables in Vercel dashboard
```

### Update Firebase Functions

```javascript
// functions/index.js
const allowedOrigins = [
  "http://localhost:3000",
  "https://your-app.vercel.app", // Add your domain
];
```

```bash
firebase deploy --only functions
```

---

## 📊 Performance

### Optimizations Included

- ✅ **Simulcast**: Multiple quality streams
- ✅ **Adaptive Streaming**: Bandwidth optimization
- ✅ **Dynacast**: Dynamic broadcast
- ✅ **Lazy Loading**: Components load on demand
- ✅ **Code Splitting**: Next.js automatic optimization

### Recommended Settings

- **1-on-1 Calls**: 720p @ 30fps
- **Group Calls (3-4)**: 480p @ 30fps
- **Group Calls (5+)**: 360p @ 24fps

---

## 🔐 Security

### Implemented

- ✅ JWT token authentication
- ✅ CORS protection
- ✅ Room-based access control
- ✅ HTTPS required for production

### Recommendations

- Add user authentication before token generation
- Implement room passwords
- Add participant limits
- Monitor usage and implement rate limiting
- Use server-side token validation

---

## 📈 Next Steps

### Immediate

1. Follow the [Quick Start Guide](./QUICK_START_GUIDE.md)
2. Copy code from [Complete Documentation](./VIDEO_CALL_INTEGRATION_DOCUMENTATION.md)
3. Test locally
4. Deploy to Vercel

### Future Enhancements

- Add screen sharing
- Implement chat messages
- Add recording functionality
- Create waiting room
- Add virtual backgrounds
- Implement analytics
- Add network quality indicators

---

## 📚 Additional Resources

### Documentation Links
- [LiveKit Docs](https://docs.livekit.io/)
- [LiveKit React Components](https://docs.livekit.io/guides/room/react/)
- [Next.js Docs](https://nextjs.org/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)

### Sample Code
- [LiveKit Examples](https://github.com/livekit/livekit-examples)
- [Next.js Examples](https://github.com/vercel/next.js/tree/canary/examples)

### Support
- [LiveKit Discord](https://livekit.io/discord)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/livekit)

---

## 🤝 Contributing

If you improve this documentation or find issues:

1. Create clear examples
2. Document edge cases
3. Update troubleshooting section
4. Share best practices

---

## 📝 License

This documentation is based on your existing Flutter implementation and uses:
- LiveKit SDK (Apache 2.0)
- Next.js (MIT)
- React (MIT)

---

## 🎉 Ready to Start?

Choose your path:

1. **Quick Setup** → [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)
2. **Complete Guide** → [VIDEO_CALL_INTEGRATION_DOCUMENTATION.md](./VIDEO_CALL_INTEGRATION_DOCUMENTATION.md)
3. **Compare Platforms** → [FLUTTER_TO_REACT_COMPARISON.md](./FLUTTER_TO_REACT_COMPARISON.md)

---

**Last Updated:** December 23, 2025  
**Created by:** Antigravity AI Assistant  
**For:** WibeChat Video Call Integration
