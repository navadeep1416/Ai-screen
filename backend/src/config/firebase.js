const admin = require('firebase-admin');
const dotenv = require('dotenv');
dotenv.config();

let db;

try {
  // Use private key from env variables. Replace literal \n with actual newlines.
  const privateKey = process.env.FIREBASE_PRIVATE_KEY 
    ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') 
    : undefined;

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: privateKey,
    })
  });
  
  db = admin.firestore();
  console.log('🔥 Firebase Admin initialized successfully');
} catch (error) {
  console.error('🔥 Firebase Admin initialization error:', error.message);
  // Do not crash server, allow it to run even if firebase fails to auth in dev
}

module.exports = { admin, db };
