# Security Setup Guide

## ⚠️ IMPORTANT: Keep Your API Keys Secure

Your Supabase credentials should NEVER be committed to version control or exposed in your frontend code.

## Setup Instructions

### 1. Copy the Template Configuration
```bash
cp lib/config/app_config.template.dart lib/config/app_config.dart
```

### 2. Fill in Your Credentials
Edit `lib/config/app_config.dart` and replace:
- `YOUR_SUPABASE_URL_HERE` with your actual Supabase URL
- `YOUR_SUPABASE_ANON_KEY_HERE` with your actual Supabase anon key

### 3. Verify .gitignore
Make sure `lib/config/app_config.dart` is in your `.gitignore` file (it should be already).

## Production Deployment

### Option 1: Environment Variables (Recommended)
```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### Option 2: Build Configuration
Set up build configurations for different environments (dev, staging, production) with different credential sets.

### Option 3: Backend Proxy (Most Secure)
- Keep all API keys on your backend
- Frontend only communicates with your backend
- Backend handles all Supabase operations
- Frontend never sees sensitive credentials

## Security Best Practices

1. **Never commit credentials** to version control
2. **Use environment variables** for production
3. **Rotate keys regularly**
4. **Use Row Level Security (RLS)** in Supabase
5. **Consider backend proxy** for sensitive operations
6. **Monitor API usage** for unusual activity

## Current Setup

The app is configured to:
- Load credentials from environment variables first
- Fall back to `app_config.dart` for development
- Show warning if no credentials are found
- Never expose credentials in the compiled app

## Troubleshooting

If you see "Supabase credentials not configured":
1. Check that `app_config.dart` exists and has valid credentials
2. Or set environment variables when running the app
3. Verify your Supabase project is active and accessible
