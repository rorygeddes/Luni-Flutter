# API Setup Instructions

To run the Luni app, you need to configure the following API keys:

## 1. Create a .env file

Create a `.env` file in the root directory of the project with the following content:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# Plaid Configuration
PLAID_CLIENT_ID=your_plaid_client_id_here
PLAID_SECRET=your_plaid_secret_here
PLAID_ENVIRONMENT=sandbox

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# App Configuration
APP_ENVIRONMENT=development
```

## 2. Get your API keys

### Supabase
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Go to Settings > API
4. Copy the Project URL and anon/public key

### Plaid
1. Go to [plaid.com](https://plaid.com)
2. Sign up for a developer account
3. Create a new app
4. Get your Client ID and Secret from the dashboard
5. Use "sandbox" environment for development

### OpenAI
1. Go to [platform.openai.com](https://platform.openai.com)
2. Create an account and get an API key
3. Make sure you have credits in your account

## 3. Database Setup

You'll need to create the following tables in your Supabase database. Run these SQL commands in the Supabase SQL editor:

```sql
-- Enable Row Level Security
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Create profiles table
CREATE TABLE profiles (
  user_id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  public_id TEXT UNIQUE,
  school TEXT,
  city TEXT,
  age INTEGER,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create categories table
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  parent_key TEXT NOT NULL,
  name TEXT NOT NULL,
  emoji TEXT NOT NULL,
  is_locked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create survey_answers table
CREATE TABLE survey_answers (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  key TEXT NOT NULL,
  value_json JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create institutions table
CREATE TABLE institutions (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  plaid_access_token TEXT NOT NULL,
  mask TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create accounts table
CREATE TABLE accounts (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  institution_id TEXT REFERENCES institutions(id) NOT NULL,
  official_name TEXT NOT NULL,
  type TEXT NOT NULL,
  subtype TEXT NOT NULL,
  mask TEXT,
  current_balance BIGINT,
  available_balance BIGINT,
  currency TEXT DEFAULT 'CAD',
  is_credit BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create transactions table
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  account_id TEXT REFERENCES accounts(id) NOT NULL,
  posted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  amount_cents BIGINT NOT NULL,
  currency TEXT DEFAULT 'CAD',
  raw_description TEXT NOT NULL,
  merchant_raw TEXT NOT NULL,
  merchant_norm TEXT NOT NULL,
  mcc TEXT,
  is_credit BOOLEAN DEFAULT FALSE,
  ai_category_id TEXT REFERENCES categories(id),
  ai_confidence DECIMAL,
  status TEXT DEFAULT 'posted' CHECK (status IN ('pending', 'posted', 'void')),
  source TEXT DEFAULT 'plaid' CHECK (source IN ('plaid', 'manual')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create queue_items table
CREATE TABLE queue_items (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  transaction_id TEXT REFERENCES transactions(id) NOT NULL,
  queue_type TEXT NOT NULL CHECK (queue_type IN ('categorize', 'split')),
  state TEXT DEFAULT 'new' CHECK (state IN ('new', 'reviewing', 'done')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create RLS policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own categories" ON categories FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Users can insert own categories" ON categories FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own survey answers" ON survey_answers FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own survey answers" ON survey_answers FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own institutions" ON institutions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own institutions" ON institutions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own accounts" ON accounts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own accounts" ON accounts FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own transactions" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own transactions" ON transactions FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own queue items" ON queue_items FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own queue items" ON queue_items FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own queue items" ON queue_items FOR UPDATE USING (auth.uid() = user_id);
```

## 4. Run the app

Once you've set up your `.env` file with the correct API keys, run:

```bash
flutter run
```

The app will first show the API configuration screen if keys are missing, then the sign-in screen, and finally the main app after authentication.
