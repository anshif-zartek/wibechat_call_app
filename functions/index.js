const functions = require("firebase-functions");
const {AccessToken} = require("livekit-server-sdk");

exports.getLivekitToken = functions.https.onRequest(async (req, res) => {
  const {room, name} = req.query;

  if (!room || !name) {
    return res.status(400).json({error: "room and name are required"});
  }

  const token = new AccessToken(
      "zartek-livekit",
      "GUmgukxUVBJyJXlEQXZRMfPdMjuJLvLU",
      {identity: name,

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
