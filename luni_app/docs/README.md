# Luni App Documentation

This folder contains all documentation and database scripts for the Luni Flutter app.

## 📁 Folder Structure

### `/sql` - Database Scripts
All SQL scripts for setting up, fixing, and managing the Supabase database.

#### Core Setup Scripts
- `setup_messaging_database.sql` - Sets up the messaging system (conversations, messages)
- `setup_friends_system.sql` - Sets up the friends/social system
- `setup_categories_database.sql` - Sets up the categories system with default categories

#### Transaction & Account Management
- `RESET_TRANSACTIONS_QUEUE.sql` - Reset all transactions to uncategorized status
- `FIX_BALANCE_TRACKING.sql` - Add opening balance tracking to accounts
- `ADD_CURRENCY_SUPPORT.sql` - Add multi-currency support
- `FIX_CREDIT_CARD_BALANCES.sql` - Ensure credit cards have negative balances

#### Categories Management
- `ADD_DEFAULT_CATEGORIES_SIMPLE.sql` - Add default categories from workflow.md
- `FIX_CATEGORIES_RLS.sql` - Fix Row Level Security policies for categories
- `CHECK_CATEGORIES.sql` - Verify categories exist and RLS is working

#### User & Profile Management
- `FIX_PROFILES_RLS.sql` - Fix RLS policies for public profile viewing
- `CHECK_USERS_FOR_SEARCH.sql` - Verify user search functionality
- `WHO_AM_I.sql` - Check current authenticated user

#### Debug & Diagnostic Scripts
- `DEBUG_BALANCE_CALCULATION.sql` - Debug account balance calculations
- `DEBUG_CREDIT_CARD_TRANSACTIONS.sql` - Debug credit card transactions
- `DEBUG_DATE_COMPARISON.sql` - Debug date comparison logic
- `DIAGNOSE_TRANSACTIONS.sql` - Comprehensive transaction diagnostics
- `CHECK_NEW_TRANSACTIONS.sql` - Check which transactions are counted as "new"
- `FIND_1_DOLLAR_TRANSACTION.sql` - Find specific transactions by amount

#### Complete Fix Scripts
- `COMPLETE_ACCOUNT_FIX.sql` - Complete fix for all account-related issues
- `COMPLETE_FIX.sql` - Consolidated fix for multiple issues
- `URGENT_FIX.sql` - Emergency fix for critical issues
- `FIX_DATABASE_NOW.sql` - Immediate database schema fixes

### `/setup` - Setup & Integration Guides
Step-by-step guides for setting up various services and features.

#### Authentication & OAuth
- `GOOGLE_SIGNIN_COMPLETE_GUIDE.md` - Complete Google Sign-In setup
- `AUTHENTICATION_FIX_SUMMARY.md` - Summary of authentication fixes
- `OAUTH_FLOW_FIX.md` - Fix OAuth redirect flow
- `MOBILE_OAUTH_FIX.md` - Fix mobile OAuth issues
- `OAUTH_LOCALHOST_FIX.md` - Fix localhost OAuth issues

#### Plaid Integration
- `PLAID_INTEGRATION_GUIDE.md` - Complete Plaid integration guide
- `PLAID_SETUP_GUIDE.md` - Initial Plaid setup
- `PLAID_PRODUCTION_SETUP.md` - Production Plaid setup
- `PLAID_CREDENTIALS_SETUP.md` - Plaid credentials configuration
- `PLAID_OAUTH_SETUP.md` - Plaid OAuth configuration
- `PLAID_ENV_SETUP.md` - Plaid environment setup
- `CANADIAN_BANKS_GUIDE.md` - Canadian banks in Plaid
- `PLAID_REAL_DATA_MIGRATION.md` - Migration from mock to real Plaid data

#### Supabase & Database
- `SUPABASE_SETUP_INSTRUCTIONS.md` - Initial Supabase setup
- `SUPABASE_EMAIL_SETUP.md` - Email authentication setup
- `DATABASE_SCHEMA_FIX.md` - Database schema fixes
- `DATABASE_MIGRATION_SUMMARY.md` - Database migration summary
- `PRODUCTION_SETUP_STEPS.md` - Production database setup

#### Environment Configuration
- `ENV_SETUP.md` - Environment variables setup
- `CREATE_ENV.md` - Create .env file guide
- `ENV_TEMPLATE.md` - Environment variables template
- `UPDATE_PLAID_CREDENTIALS.md` - Update Plaid credentials
- `PLAID_CREDENTIALS_SETUP.md` - Plaid credentials setup

#### Feature-Specific Guides
- `MESSAGING_SYSTEM_COMPLETE.md` - Complete messaging system guide
- `PUBLIC_PROFILES_SYSTEM.md` - Public profiles system guide
- `CATEGORIES_SYSTEM_COMPLETE.md` - Complete categories system guide
- `TRANSACTION_WORKFLOW_COMPLETE.md` - Transaction workflow guide
- `TRANSACTION_SYNC_GUIDE.md` - Transaction sync feature guide
- `OPENING_BALANCE_SYSTEM.md` - Opening balance system guide

#### Deployment
- `DEPLOY_TO_LUNI_CA.md` - Deploy OAuth redirect to luni.ca
- `OAUTH_FLOW_FIX.md` - OAuth flow deployment fixes

## 📝 Quick Start

1. **Initial Setup**: Start with `SUPABASE_SETUP_INSTRUCTIONS.md` and `ENV_SETUP.md`
2. **Database Setup**: Run `setup_*.sql` scripts in the SQL editor
3. **Authentication**: Follow `GOOGLE_SIGNIN_COMPLETE_GUIDE.md`
4. **Plaid Integration**: Follow `PLAID_INTEGRATION_GUIDE.md`
5. **Categories**: Run `ADD_DEFAULT_CATEGORIES_SIMPLE.sql`

## 🔧 Common Tasks

### Reset Transaction Queue
Run `docs/sql/RESET_TRANSACTIONS_QUEUE.sql` in Supabase SQL editor

### Add Default Categories
Run `docs/sql/ADD_DEFAULT_CATEGORIES_SIMPLE.sql` in Supabase SQL editor

### Fix Account Balances
Run `docs/sql/COMPLETE_ACCOUNT_FIX.sql` in Supabase SQL editor

### Debug Issues
Use the appropriate `DEBUG_*.sql` or `CHECK_*.sql` script from `docs/sql/`

## 📚 Additional Resources

- **Main README**: `../README.md` (app overview and development setup)
- **Product Docs**: `../Product/` (product requirements and specifications)
- **Figma Integration**: `../FIGMA_INTEGRATION_GUIDE.md`

## 🗂️ Archive

Old/deprecated files are kept in `old_supabase/` folders for reference.

