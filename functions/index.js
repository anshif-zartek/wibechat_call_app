const functions = require("firebase-functions");
const {AccessToken} = require("livekit-server-sdk");

exports.getLivekitToken = functions.https.onRequest(async (req, res) => {
  // CORS Configuration
  const allowedOrigins = [
    "https://wibechat-demo.web.app",
    "http://localhost:5000",
  ];

  const origin = req.headers.origin;
  if (allowedOrigins.includes(origin)) {
    res.set("Access-Control-Allow-Origin", origin);
  }

  res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type");
  res.set("Access-Control-Max-Age", "3600");

  // Handle preflight OPTIONS request
  if (req.method === "OPTIONS") {
    return res.status(204).send("");
  }

  const {room, name} = req.query;

  if (!room || !name) {
    return res.status(400).json({error: "room and name are required"});
  }

  const token = new AccessToken(
      "zartek-livekit",
      "GUmgukxUVBJyJXlEQXZRMfPdMjuJLvLU",
      {
        identity: name,

      },
  );

  token.addGrant({
    room,
    roomJoin: true,
    canPublish: true,
    canSubscribe: true,
  });

  const jwt = await token.toJwt(); // 🔑 THIS WAS MISSING

  return res.json({token: jwt});
});
