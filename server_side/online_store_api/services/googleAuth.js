// services/googleAuth.js
// Verify Google "Sign in with Google" ID tokens server-side.
const { OAuth2Client } = require('google-auth-library');
const axios = require('axios');
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

// Verify a Google OAuth access token and return normalized profile, or throw.
// Needed for Flutter web: google_sign_in_web (Google Identity Services) does not
// return an ID token from signIn(), only an access token.
async function verifyGoogleAccessToken(accessToken) {
  const audiences = getAllowedAudiences();
  if (audiences.length === 0) {
    throw new Error('Google auth is not configured (set GOOGLE_CLIENT_ID)');
  }
  // tokeninfo validates the token and tells us which client it was issued to.
  const { data: info } = await axios.get('https://oauth2.googleapis.com/tokeninfo', {
    params: { access_token: accessToken },
  });
  const issuedTo = info.aud || info.azp;
  if (!audiences.includes(issuedTo)) {
    throw new Error('Google access token was issued to an unknown client');
  }
  const { data: p } = await axios.get('https://www.googleapis.com/oauth2/v3/userinfo', {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (!p.email) {
    throw new Error('Google profile did not contain an email');
  }
  return {
    googleId: p.sub,
    email: String(p.email).toLowerCase(),
    emailVerified: p.email_verified === true || p.email_verified === 'true',
    name: p.name,
    avatar: p.picture,
  };
}

module.exports = { hasGoogleEnv, verifyGoogleIdToken, verifyGoogleAccessToken };
