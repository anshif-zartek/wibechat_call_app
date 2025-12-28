# Video Call Integration - Quick Start

> **Frontend-only implementation using hosted API & WebSocket**

## 🚀 Get Started in 3 Minutes

```bash
# 1. Create Next.js app
npx create-next-app@latest video-call-app --typescript --tailwind --app
cd video-call-app

# 2. Install dependencies
npm install @livekit/components-react livekit-client axios

# 3. Create environment file
cat > .env.local << EOF
NEXT_PUBLIC_LIVEKIT_URL=wss://call.wibechat.com
NEXT_PUBLIC_TOKEN_API=https://getlivekittoken-3xpiwheqja-uc.a.run.app
EOF

# 4. Start development
npm run dev
```

## 📋 What's Already Hosted

| Service | Status | URL |
|---------|--------|-----|
| LiveKit WebSocket Server | 🟢 Live | `wss://call.wibechat.com` |
| Token Generation API | 🟢 Live | `https://getlivekittoken-3xpiwheqja-uc.a.run.app` |

**You don't need to deploy or configure any backend services!**

## 🛠️ What to Build

Follow the complete implementation guide in [`VIDEO_CALL_INTEGRATION_DOCUMENTATION.md`](./VIDEO_CALL_INTEGRATION_DOCUMENTATION.md)

### Components Needed:

1. **Join Screen** (`app/join/page.js`)
   - User enters name and room ID
   - Fetches token from hosted API
   - Requests camera/mic permissions

2. **Room Screen** (`app/room/[roomId]/page.js`)
   - Main video call interface
   - Participant layout (PIP or Grid)
   - Real-time updates

3. **Video Component** (`components/ParticipantVideo.jsx`)
   - Displays participant video
   - Fallback for disabled cameras
   - Shows participant info

4. **Control Bar** (`components/ControlBar.jsx`)
   - Mute/Unmute microphone
   - Toggle camera on/off
   - Flip camera (mobile)
   - End call button

5. **Utilities** (`lib/livekit.js`)
   - Token fetching function
   - Permission requests
   - Configuration

## 📚 Full Documentation

See [`VIDEO_CALL_INTEGRATION_DOCUMENTATION.md`](./VIDEO_CALL_INTEGRATION_DOCUMENTATION.md) for:

- ✅ Complete code examples for all components
- ✅ Step-by-step implementation guide
- ✅ Deployment instructions (Vercel/Netlify)
- ✅ Troubleshooting guide
- ✅ Security best practices
- ✅ Advanced features & enhancements

## 🎯 Features

- ✅ One-on-one video calls with PIP view
- ✅ Group video calls with grid layout
- ✅ Real-time participant tracking
- ✅ Audio/Video controls (mute, camera toggle, flip)
- ✅ Token-based authentication
- ✅ Modern UI with Tailwind CSS
- ✅ Responsive design
- ✅ Production ready

## 🚢 Deploy to Production

### Vercel (Recommended)

```bash
npm i -g vercel
vercel --prod
```

Add environment variables in Vercel dashboard:
- `NEXT_PUBLIC_LIVEKIT_URL`: `wss://call.wibechat.com`
- `NEXT_PUBLIC_TOKEN_API`: `https://getlivekittoken-3xpiwheqja-uc.a.run.app`

### Netlify

```bash
npm i -g netlify-cli
netlify deploy --prod
```

Add the same environment variables in Netlify dashboard.

## 🧪 Testing

### Test API Connection

```bash
curl "https://getlivekittoken-3xpiwheqja-uc.a.run.app?room=test-room&name=TestUser"
```

Should return:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Test Video Call

1. Open your app: `http://localhost:3000`
2. Enter name and room ID
3. Click "Join Now"
4. Allow camera/microphone permissions
5. Open another browser tab/window
6. Join the same room with a different name
7. You should see both participants!

## 📖 API Reference

### Token Generation Endpoint

**GET** `https://getlivekittoken-3xpiwheqja-uc.a.run.app`

**Parameters:**
- `room` (required): Room identifier
- `name` (required): Participant name

**Response:**
```json
{
  "token": "eyJhbGci..."
}
```

## 🔒 Security Notes

- ✅ Backend handles token generation (already secured)
- ✅ Tokens are short-lived JWT tokens
- ✅ CORS configured for your domains
- ✅ Use HTTPS in production (required for WebRTC)
- ✅ Never expose API credentials in frontend code

## 🆘 Need Help?

### Common Issues

**Camera not working**: Ensure HTTPS and check browser permissions  
**Token fetch fails**: Verify API endpoint is accessible  
**Cannot connect**: Check WebSocket URL and firewall settings  
**Quality issues**: Check network bandwidth (min 1 Mbps)

### Resources

- 📘 [Complete Documentation](./VIDEO_CALL_INTEGRATION_DOCUMENTATION.md)
- 🌐 [LiveKit Docs](https://docs.livekit.io/)
- 💬 [LiveKit Discord](https://livekit.io/discord)
- 🔧 [Next.js Docs](https://nextjs.org/docs)

## 💡 Next Steps

After basic implementation:

1. **Customize UI** - Match your brand colors and style
2. **Add Features** - Screen sharing, chat, recording
3. **Analytics** - Track usage with Google Analytics
4. **Error Handling** - Add Sentry for monitoring
5. **Testing** - Write tests for critical flows

## 📝 License

Your license here

---

**Built with ❤️ using Next.js, React, Tailwind CSS, and LiveKit**
