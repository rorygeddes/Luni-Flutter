# Setup & Integration Guides

Step-by-step guides for setting up Luni app services and features.

## 🚀 Getting Started (In Order)

1. **Environment Setup**
   - `ENV_SETUP.md` - Complete environment variables guide
   - `CREATE_ENV.md` - Create your .env file
   - `ENV_TEMPLATE.md` - Template reference

2. **Database Setup**
   - `SUPABASE_SETUP_INSTRUCTIONS.md` - Initial Supabase setup
   - `SUPABASE_EMAIL_SETUP.md` - Email authentication
   - Run SQL scripts from `../sql/`

3. **Authentication**
   - `GOOGLE_SIGNIN_COMPLETE_GUIDE.md` - Google Sign-In setup
   - `AUTHENTICATION_FIX_SUMMARY.md` - Common fixes

4. **Plaid Integration**
   - `PLAID_INTEGRATION_GUIDE.md` - Complete integration guide
   - `PLAID_SETUP_GUIDE.md` - Initial setup
   - `PLAID_CREDENTIALS_SETUP.md` - Configure credentials

5. **Production Deployment**
   - `PRODUCTION_SETUP_STEPS.md` - Production checklist
   - `PLAID_PRODUCTION_SETUP.md` - Production Plaid config
   - `DEPLOY_TO_LUNI_CA.md` - Deploy OAuth redirect

## 📚 Guides by Category

### 🔐 Authentication & OAuth
- `GOOGLE_SIGNIN_COMPLETE_GUIDE.md` ⭐ Main guide
- `GOOGLE_SIGNIN_SETUP.md` - Quick setup
- `AUTHENTICATION_FIX_SUMMARY.md` - Troubleshooting
- `OAUTH_FLOW_FIX.md` - OAuth redirect fixes
- `MOBILE_OAUTH_FIX.md` - Mobile-specific fixes
- `OAUTH_LOCALHOST_FIX.md` - Local development fixes
- `QUICK_OAUTH_SETUP.md` - Quick reference

### 💳 Plaid Integration
- `PLAID_INTEGRATION_GUIDE.md` ⭐ Complete guide
- `PLAID_SETUP_GUIDE.md` - Initial setup
- `PLAID_PRODUCTION_SETUP.md` - Production config
- `PLAID_CREDENTIALS_SETUP.md` - Credentials management
- `PLAID_OAUTH_SETUP.md` - OAuth configuration
- `PLAID_ENV_SETUP.md` - Environment setup
- `UPDATE_PLAID_CREDENTIALS.md` - Update credentials
- `CANADIAN_BANKS_GUIDE.md` - Canadian banks support
- `PLAID_REAL_DATA_MIGRATION.md` - Migration guide

### 🗄️ Database & Supabase
- `SUPABASE_SETUP_INSTRUCTIONS.md` ⭐ Main setup
- `SUPABASE_EMAIL_SETUP.md` - Email auth
- `DATABASE_SCHEMA_FIX.md` - Schema fixes
- `DATABASE_MIGRATION_SUMMARY.md` - Migration summary
- `PRODUCTION_SETUP_STEPS.md` - Production database

### ⚙️ Environment & Configuration
- `ENV_SETUP.md` ⭐ Main guide
- `CREATE_ENV.md` - Create .env file
- `ENV_TEMPLATE.md` - Template reference
- `UPDATE_PLAID_CREDENTIALS.md` - Update config
- `PLAID_ENV_SETUP.md` - Plaid-specific config

### 🎯 Feature-Specific Guides
- `MESSAGING_SYSTEM_COMPLETE.md` - Messaging system
- `PUBLIC_PROFILES_SYSTEM.md` - Public profiles
- `CATEGORIES_SYSTEM_COMPLETE.md` - Categories system
- `TRANSACTION_WORKFLOW_COMPLETE.md` - Transaction workflow
- `TRANSACTION_SYNC_GUIDE.md` - Transaction sync
- `OPENING_BALANCE_SYSTEM.md` - Opening balance tracking

### 🚀 Deployment
- `DEPLOY_TO_LUNI_CA.md` - Deploy to luni.ca
- `PRODUCTION_SETUP_STEPS.md` - Production checklist
- `PLAID_PRODUCTION_SETUP.md` - Production Plaid

## 🔍 Quick Reference

### Environment Variables Needed
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
GOOGLE_WEB_CLIENT_ID=
GOOGLE_IOS_CLIENT_ID=
PLAID_CLIENT_ID=
PLAID_SECRET=
PLAID_ENV=sandbox|production
BACKEND_URL=http://localhost:3000
```

### Common Setup Issues

#### Google Sign-In Not Working
→ See `GOOGLE_SIGNIN_COMPLETE_GUIDE.md`
→ Check `AUTHENTICATION_FIX_SUMMARY.md`

#### Plaid Connection Failing
→ See `PLAID_INTEGRATION_GUIDE.md`
→ Check `PLAID_OAUTH_SETUP.md`

#### OAuth Redirect Issues
→ See `OAUTH_FLOW_FIX.md`
→ Check `MOBILE_OAUTH_FIX.md`

#### Database Errors
→ See `DATABASE_SCHEMA_FIX.md`
→ Run relevant SQL from `../sql/`

#### Categories Not Showing
→ See `CATEGORIES_SYSTEM_COMPLETE.md`
→ Run `../sql/ADD_DEFAULT_CATEGORIES_SIMPLE.sql`

## 📋 Setup Checklist

- [ ] Create `.env` file (`CREATE_ENV.md`)
- [ ] Set up Supabase (`SUPABASE_SETUP_INSTRUCTIONS.md`)
- [ ] Run database setup scripts (`../sql/setup_*.sql`)
- [ ] Configure Google Sign-In (`GOOGLE_SIGNIN_COMPLETE_GUIDE.md`)
- [ ] Set up Plaid (`PLAID_INTEGRATION_GUIDE.md`)
- [ ] Add default categories (`../sql/ADD_DEFAULT_CATEGORIES_SIMPLE.sql`)
- [ ] Test authentication flow
- [ ] Test Plaid connection
- [ ] Verify transaction queue
- [ ] Check category display

## 🆘 Need Help?

1. Check the relevant guide in this folder
2. Look for related SQL scripts in `../sql/`
3. Check `../README.md` for main app documentation
4. Review error logs and match to troubleshooting guides

