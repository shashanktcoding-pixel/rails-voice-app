# Frontend Integration Guide

## Overview
This Next.js frontend is now integrated with the Rails voice generation API backend.

## Architecture
```
User → Next.js (localhost:3001) → Rails API (localhost:3000) → ElevenLabs → Audio File
```

The integration works as follows:
1. User enters text in the Next.js frontend
2. Frontend calls `/api/tts` (Next.js API route)
3. Next.js route calls Rails `POST /generate_voice` to create a job
4. Next.js polls Rails `GET /voice_status/:id` until job completes
5. Once complete, Next.js fetches the audio file from Rails
6. Audio is returned to the browser for playback

## Running the Full Stack

### Terminal 1: Redis
```bash
redis-server
```

### Terminal 2: Sidekiq (Rails Background Jobs)
```bash
cd /Users/shashank/rails-voice-app
bundle exec sidekiq
```

### Terminal 3: Rails API Server
```bash
cd /Users/shashank/rails-voice-app
rails server -p 3000
```

### Terminal 4: Next.js Frontend
```bash
cd /Users/shashank/rails-voice-app/frontend
pnpm install  # First time only
pnpm dev
```

## Access the App
Open your browser to: **http://localhost:3001**

## Configuration

### Frontend (.env.local)
```
RAILS_API_URL=http://localhost:3000
```

### Backend (.env)
```
ELEVEN_LABS_API_KEY=sk_a2afbd6a2bb628d6572b1d6c3d9dd0969ed52b98a9826326
ELEVEN_LABS_VOICE_ID=EXAVITQu4vr4xnSDxMaL
```

## Features
- ✅ Text-to-speech generation using ElevenLabs
- ✅ Asynchronous processing with Sidekiq
- ✅ Real-time status polling
- ✅ Audio history and playback
- ✅ Download generated audio files
- ✅ Beautiful UI with dark mode support

## API Flow
1. **Create Job**: `POST /generate_voice` → Returns `{id, status, status_url}`
2. **Poll Status**: `GET /voice_status/:id` → Returns `{id, status, audio_url}`
3. **Fetch Audio**: `GET /audio/voice_X_timestamp.mp3` → Returns MP3 file

## Troubleshooting

### CORS Errors
- Ensure rack-cors is installed: `bundle install`
- Restart Rails server after CORS config changes

### Audio Not Generating
- Check Sidekiq is running and processing jobs
- Check Rails logs for ElevenLabs API errors
- Verify ELEVEN_LABS_API_KEY is valid

### Frontend Can't Connect
- Ensure Rails is running on port 3000
- Check RAILS_API_URL in `.env.local`
- Verify CORS is enabled in Rails

## Tech Stack
- **Frontend**: Next.js 16, React 19, TypeScript, Tailwind CSS
- **Backend**: Rails 7.1, Sidekiq 8.0, PostgreSQL
- **TTS**: ElevenLabs API (eleven_turbo_v2_5 model)
- **Storage**: Local filesystem (public/audio/)
