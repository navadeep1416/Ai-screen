# Nava Screen AI Backend

A robust, production-ready Node.js/Express backend powering the Nava Screen AI Android assistant.

## Features
- **AI Engine**: Powered by Groq (LLaMA3) for hyper-fast chat generation.
- **Vision Engine**: Powered by Gemini 1.5 Flash for screenshot/reel analysis.
- **Relationship Modes**: 11 configured modes modifying AI behavior.
- **Firebase Ready**: Connects to Firestore via Firebase Admin SDK.
- **Scalable Architecture**: Modular routes, controllers, and services.

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Configure environment:
   Copy `.env.example` to `.env` and fill in your Firebase Admin credentials. The API keys are already provided in the example for reference.

3. Run for development:
   ```bash
   npm run dev
   ```

4. Run for production:
   ```bash
   npm start
   ```

## Deployment
This backend is fully configured for deployment on Railway.app. Simply connect your GitHub repository to Railway, and it will use the provided `railway.json` and `package.json` to build and deploy automatically.
