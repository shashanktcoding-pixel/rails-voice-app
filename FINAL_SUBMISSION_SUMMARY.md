#AI Voice Generation App

This document provides a quick look at our recently completed AI-powered voice generation application.

## Live Application & Source Code

You can try out the live application here:
- **Frontend:** https://observant-generosity-production.up.railway.app

- **API Server:** https://web-production-5146c.up.railway.app

- **GitHub Repository:** https://github.com/shashanktcoding-pixel/rails-voice-app

## How It Was Built: Our Design Philosophy

We designed the application with a modern, decoupled architecture to keep it flexible and maintainable. The backend is a powerful Ruby on Rails API, while the frontend is a sleek, responsive interface built with Next.js (React).

Here are some of the key decisions we made:

**Why Supabase?**
Supabase for handling file storage and user authentication. It has a generous free tier, is incredibly easy to set up, and its built-in features like a CDN and Google OAuth support saved us a lot of development time.

**Making it Feel Fast with Background Jobs**
Generating audio can be slow. To ensure the user has a smooth experience without long waiting times, we used Sidekiq to process all voice generation requests in the background. When a user submits text, the API immediately responds, and the audio is generated behind the scenes.

**Protecting the App**
To prevent abuse and protect our API quotas, we implemented rate limiting. This ensures the application remains stable and available for everyone. We also followed RESTful design principles, which makes the API predictable and easy to work with.