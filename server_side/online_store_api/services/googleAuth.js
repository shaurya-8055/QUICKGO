// services/googleAuth.js
// Verify Google "Sign in with Google" ID tokens server-side.
const { OAuth2Client } = require('google-auth-library');
require('dotenv').config();

// Accept tokens issued for any of our configured OAuth client IDs
// (web, android, ios can each have their own client ID / audience).
function getAllowedAudiences() {
  return [
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_ID_WEB,
    process.env.GOOGLE_CLIENT_ID_ANDROID,
    process.env.GOOGLE_CLIENT_ID_IOS,
  ].filter(Boolean);
}

function hasGoogleEnv() {
  return getAllowedAudiences().length > 0;
}

const client = new OAuth2Client();

// Verify an ID token and return normalized profile, or throw.
async function verifyGoogleIdToken(idToken) {
  const audiences = getAllowedAudiences();
  if (audiences.length === 0) {
    throw new Error('Google auth is not configured (set GOOGLE_CLIENT_ID)');
  }
  const ticket = await client.verifyIdToken({
    idToken,
    audience: audiences,
  });
  const payload = ticket.getPayload();
  if (!payload || !payload.email) {
    throw new Error('Google token did not contain an email');
  }
  return {
    googleId: payload.sub,
    email: String(payload.email).toLowerCase(),
    emailVerified: !!payload.email_verified,
    name: payload.name,
    avatar: payload.picture,
  };
}

module.exports = { hasGoogleEnv, verifyGoogleIdToken };
