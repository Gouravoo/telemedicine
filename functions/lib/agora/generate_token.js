"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateAgoraToken = void 0;
const functions = require("firebase-functions");
const agora_access_token_1 = require("agora-access-token");
/**
 * Generate Agora RTC Token
 *
 * Called from Flutter app before joining a video call.
 * The App Certificate is stored securely here — NEVER on the client.
 *
 * @param channelName - The Agora channel name (appointment ID)
 * @param uid - User ID (number)
 * @returns { token: string }
 */
// ─── Agora Credentials ───
// App Certificate is SECRET — only used server-side
const APP_ID = "6ef4712b229a4c9691633f4f6cd8d42d";
const APP_CERTIFICATE = "917763fe2c1343cfb52db9f52458c5bf";
exports.generateAgoraToken = functions.https.onCall(async (data, context) => {
    // Verify user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated to generate a token");
    }
    const channelName = data.channelName;
    const uid = parseInt(data.uid) || 0;
    if (!channelName) {
        throw new functions.https.HttpsError("invalid-argument", "channelName is required");
    }
    // Token expires in 1 hour (3600 seconds)
    const expirationTimeInSeconds = 3600;
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;
    // Build the token
    const token = agora_access_token_1.RtcTokenBuilder.buildTokenWithUid(APP_ID, APP_CERTIFICATE, channelName, uid, agora_access_token_1.RtcRole.PUBLISHER, privilegeExpiredTs);
    return { token };
});
//# sourceMappingURL=generate_token.js.map