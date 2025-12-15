# Deployment Guide for Rails Voice App

## Local Setup Verified ✅

Both the Rails backend and Next.js frontend have been tested locally and are working correctly:

- **Rails API**: Running on `http://localhost:3000`
- **Frontend**: Running on `http://localhost:3001`
- **ElevenLabs Integration**: ✅ Working
- **Supabase Storage**: ✅ Working
- **Sidekiq Background Jobs**: ✅ Working

## Railway Deployment Steps

### Prerequisites

1. Create a Railway account at https://railway.app
2. Install Railway CLI:
   ```bash
   npm i -g @railway/cli
   ```
3. Login to Railway:
   ```bash
   railway login
   ```

### Step 1: Deploy the Rails Backend

1. **Create a new Railway project:**
   ```bash
   railway init
   ```

2. **Add PostgreSQL database:**
   - In Railway dashboard, click "New" → "Database" → "PostgreSQL"
   - Railway will automatically set the `DATABASE_URL` environment variable

3. **Add Redis:**
   - Click "New" → "Database" → "Redis"
   - Railway will automatically set the `REDIS_URL` environment variable

4. **Set environment variables in Railway:**
   ```bash
   railway variables set ELEVEN_LABS_API_KEY=sk_a2afbd6a2bb628d6572b1d6c3d9dd0969ed52b98a9826326
   railway variables set ELEVEN_LABS_VOICE_ID=EXAVITQu4vr4xnSDxMaL
   railway variables set SUPABASE_URL=https://uscjzrcnayeimwhoncyz.supabase.co
   railway variables set SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzY2p6cmNuYXllaW13aG9uY3l6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0MzgxOTQsImV4cCI6MjA4MTAxNDE5NH0.dQyrczhNA5AzrPSkgQZFYaftXJWk3CQIWLu7izctYFE
   railway variables set SUPABASE_BUCKET_NAME=voice-generations
   railway variables set RAILS_ENV=production
   railway variables set RACK_ENV=production
   railway variables set RAILS_LOG_TO_STDOUT=true
   railway variables set RAILS_SERVE_STATIC_FILES=true
   ```

5. **Deploy:**
   ```bash
   railway up
   ```

6. **Run database migrations:**
   ```bash
   railway run rails db:migrate
   ```

### Step 2: Deploy the Frontend

1. **Create a new Railway service for frontend:**
   - In Railway dashboard, click "New" → "Empty Service"
   - Link your GitHub repository
   - Set root directory to `/frontend`

2. **Set environment variables for frontend:**
   - `NEXT_PUBLIC_RAILS_API_URL`: Your Rails backend URL from Railway (e.g., `https://your-app.railway.app`)

3. **Deploy frontend** - Railway will auto-deploy from GitHub

### Step 3: Configure CORS

Update `config/initializers/cors.rb` to allow requests from your frontend domain:

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "your-frontend-domain.railway.app"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false
  end
end
```

## Alternative: Single Deployment with Dockerfile

Railway also supports deploying both frontend and backend together. The existing `Dockerfile` is configured for this purpose.

## Environment Variables Checklist

### Required for Rails Backend:
- [x] `DATABASE_URL` (auto-set by Railway PostgreSQL)
- [x] `REDIS_URL` (auto-set by Railway Redis)
- [x] `ELEVEN_LABS_API_KEY`
- [x] `ELEVEN_LABS_VOICE_ID`
- [x] `SUPABASE_URL`
- [x] `SUPABASE_ANON_KEY`
- [x] `SUPABASE_BUCKET_NAME`
- [x] `RAILS_ENV=production`
- [x] `RACK_ENV=production`

### Required for Frontend:
- [x] `NEXT_PUBLIC_RAILS_API_URL` (set to your Railway backend URL)

## Testing the Deployment

After deployment:

1. Visit your frontend URL
2. Enter some text in the textarea
3. Click "Generate Speech"
4. Wait for processing (should take 3-5 seconds)
5. Audio should appear in the history with a working play button

## Troubleshooting

### If voice generation fails:
1. Check Railway logs: `railway logs`
2. Verify all environment variables are set correctly
3. Ensure Sidekiq worker process is running (check Procfile)
4. Verify Supabase bucket "voice-generations" exists and is public

### If frontend can't connect to backend:
1. Check CORS configuration
2. Verify `NEXT_PUBLIC_RAILS_API_URL` is set correctly
3. Check Railway service is running

## Success Criteria

- ✅ Rails API responds to health check at `/up`
- ✅ POST to `/generate_voice` creates a job
- ✅ Sidekiq processes the job
- ✅ ElevenLabs generates audio
- ✅ Supabase stores audio file
- ✅ Frontend can trigger and play audio

## Current Status

**Local Testing**: ✅ COMPLETE
- Backend API working
- Frontend working
- ElevenLabs integration working
- Supabase storage working
- End-to-end flow verified

**Next Step**: Deploy to Railway following the steps above.
