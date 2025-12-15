# Rails Voice App

A full-stack voice generation application using Ruby on Rails, Next.js, ElevenLabs API, and Supabase Storage.

## Features

- 🎤 **Text-to-Speech**: Convert text to natural-sounding speech using ElevenLabs API
- ☁️ **Cloud Storage**: Audio files stored on Supabase Storage
- ⚡ **Background Processing**: Async job processing with Sidekiq
- 🎨 **Modern UI**: Beautiful Next.js frontend with Tailwind CSS
- 📊 **Audio History**: View and manage generated audio files
- 🔒 **Rate Limiting**: Built-in rate limiting with Rack::Attack

## Tech Stack

### Backend
- **Framework**: Ruby on Rails 7.1.3
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq + Redis
- **APIs**: ElevenLabs (TTS), Supabase (Storage)
- **Ruby Version**: 3.4.3

### Frontend
- **Framework**: Next.js 16
- **UI**: React 19, Tailwind CSS, shadcn/ui
- **Language**: TypeScript

## Prerequisites

- Ruby 3.4.3
- PostgreSQL
- Redis
- Node.js 18+
- pnpm

## Local Setup

### 1. Clone the repository

```bash
git clone https://github.com/shashanktcoding-pixel/rails-voice-app.git
cd rails-voice-app
```

### 2. Backend Setup

```bash
# Install dependencies
bundle install

# Create and setup database
rails db:create db:migrate

# Copy environment variables
cp .env.example .env
```

Edit `.env` and add your API keys:

```env
ELEVEN_LABS_API_KEY=your_elevenlabs_api_key
ELEVEN_LABS_VOICE_ID=your_voice_id
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_BUCKET_NAME=voice-generations
```

### 3. Start Backend Services

```bash
# Terminal 1: Rails server
rails server

# Terminal 2: Sidekiq
bundle exec sidekiq
```

The API will be available at `http://localhost:3000`

### 4. Frontend Setup

```bash
cd frontend
pnpm install

# Create .env.local
echo "RAILS_API_URL=http://localhost:3000" > .env.local

# Start dev server
pnpm dev
```

The frontend will be available at `http://localhost:3001`

## API Endpoints

### POST /generate_voice
Generate voice from text.

**Request:**
```json
{
  "text": "Hello, this is a test."
}
```

**Response:**
```json
{
  "id": 1,
  "status": "pending",
  "message": "Voice generation started",
  "status_url": "http://localhost:3000/voice_status/1"
}
```

### GET /voice_status/:id
Check generation status.

**Response (completed):**
```json
{
  "id": 1,
  "status": "completed",
  "text": "Hello, this is a test.",
  "audio_url": "https://your-supabase-url/storage/v1/object/public/voice-generations/voice_1_123456.mp3"
}
```

## Architecture

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   Next.js UI    │─────▶│   Rails API      │─────▶│  ElevenLabs API │
│  (Frontend)     │      │   (Backend)      │      │  (TTS Service)  │
└─────────────────┘      └──────────────────┘      └─────────────────┘
                                  │
                                  │
                    ┌─────────────┴────────────────┐
                    │                              │
           ┌────────▼────────┐         ┌──────────▼─────────┐
           │  Sidekiq Worker │         │ Supabase Storage   │
           │  (Background)   │         │ (Audio Files)      │
           └─────────────────┘         └────────────────────┘
                    │
           ┌────────▼────────┐
           │   PostgreSQL    │
           │   (Database)    │
           └─────────────────┘
```

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions to Railway.

## Rate Limiting

The API includes rate limiting:
- **General**: 60 requests per minute per IP
- **Voice Generation**: 10 requests per minute per IP

## Testing

```bash
# Run tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec
```

## Project Structure

```
.
├── app/
│   ├── controllers/      # API controllers
│   ├── jobs/            # Sidekiq background jobs
│   ├── models/          # ActiveRecord models
│   └── services/        # Service objects (ElevenLabs, Supabase)
├── frontend/
│   ├── app/             # Next.js app directory
│   ├── components/      # React components
│   └── public/          # Static assets
├── config/              # Rails configuration
├── db/                  # Database migrations
└── spec/               # RSpec tests
```

## License

MIT

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
