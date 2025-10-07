This is the ai version I asked it to prompt for me to enforce the additions I want to add into the flutter app.

Luni — Product & Integration Overview

Goal
Help students understand spending and stay on track with goals using automated bank ingestion (Plaid), lightweight AI categorization, and a low-friction review loop (5 at a time). Luni exposes a public-ish profile (Venmo-style) for easy money requests/splits, while keeping finance data private by default.

Core Concepts

Money Pool (Present View): real-time sum of cash & debt (debit + checking + savings − credit).

Monthly View: budget vs. actual per category for the active cycle.

Index: a simple benchmark line (self-competition) used to nudge behavior.

Queues: new/uncategorized transactions and “splits to resolve” shown in batches of 5.

Architecture (high level)

Client: Flutter (Dart)

Backend: Supabase (Postgres + Row Level Security + Edge Functions)

Bank Data: Plaid Link (Link Token → Public Token → Access Token); Transactions & Webhooks

AI: OpenAI (normalize merchant name, categorize + confidence, remember rules)

Auth: Supabase Auth (email/password + optional social)

Storage: Supabase Storage (profile avatars)

Onboarding → Setup → Daily Loop
1) Auth & Profile (Venmo-style identity)

UI: Sign up / Sign in → Name, @username, password; upload profile image.

System: Create user, profile, reserve unique @username, upload avatar, generate public_id (short code/QR).

Outcome: Public profile card (name, @username, avatar, university & city once collected). Only minimal fields are public.

2) Personal Context (one question per screen)

Questions: school, city, age, top 3 motivations (chips), jobs/hours/wage, other income (parents/aid/side hustle), regular savings/investing withdrawals, rent, grocery spend per trip + frequency, other recurring expenses, frequent merchants (logos grid + text add).

System: Store as survey_answers; derive cycle income and base recurring expenses.

Outcome: Preconfig default category tree; seed “favorites” for faster categorization.

3) Category Model (locked parents + editable subs)

Parents you defined (locked):

Housing & Utilities: Rent; Utilities; Internet; Furniture/essentials

Food & Drink: Groceries; Coffee Shop; Nicer Meals out; Snacks & Fast food

Transportation: Transit pass; Gas; Car insurance & maintenance; Rideshare; Bike/scooter

Education: Tuition & fees; Textbooks; Supplies

Personal & Social: Clothing; Entertainment; Nights out; Sports & Hobbies; Alcohol / substances; Subscriptions

Health & Wellness: Insurance; Medication/pharmacy; Fitness/Gym; Haircuts

Savings & Debt: Emergency fund; Credit card payments; Student loans

Student Income: Employment; Family Support; Loans & Aid; Other/Bonus

UI: Parent-by-parent screens; allow adding personal sub-accounts (e.g., “Starbucks,” “UBC Rec”).

System: Write categories (parent=locked, sub=user_addable), link favorites.

4) Home (empty state)

UI Tabs: Home (Present Value + “Connect bank accounts”), Track (Categories & budgets), Plus (+ Queue), Split, Profile.

System: Show projected budgets from survey answers until Plaid data lands.

5) Bank Connection (Plaid Link)

UI: CTA on Home (“Connect bank accounts”).

Flow:

Call backend to create Plaid Link Token

Launch Plaid Link in Flutter → get public_token

Exchange for access_token (server) + store per institution

Initial backfill: pull 90 days of transactions; normalize & classify; enqueue

Subscribe to Plaid webhooks (TRANSACTIONS: added/modified/removed)

Outcome: Real Accounts list (swipe) with balances; Track tab shows budgets seeded from 90-day spend.

6) Daily Loop (AI + Queues, 5 at a time)

Ingestion: New transactions → normalize merchant → AI categorize (top guess + confidence + rationale) → enqueue if uncertain or rule missing.

UI (+ tab): “Items in Queue”; grouped by date; each row shows: Merchant (simplified), amount (green/red), Parent → Sub (editable), “Split” button.

Batching: 5 per page with Submit to persist; next 5 load.

Rules: “Remember for next time” toggle creates a user rule (merchant → subcategory, confidence threshold).

Posting:

Category assignment updates Monthly View actuals.

Present Value always uses live account balances; category only affects budget progress (not bank totals).

7) Split Queue

From + tab: “Split” sends item to Split Queue.

UI: Pick group (House/Family/Custom) → then members; choose equal, shares, or exact amounts; toggle Public in group chat vs Private DM; up to 5 items per submit.

System: Write splits records + debts; optional notification (push/DM).

Note: Split affects the owed/owing ledger, not the bank balance. Category impact remains in Track.

Present Value, Budgets & Month Close

Present Value: sum(checking+savings+cash) − sum(credit card balances).

Budget Seeding: from survey & the 90-day Plaid rollup (avg per category).

Month Close: roll over unspent (by category policy), reset queues, snapshot Index.

AI Pipeline (OpenAI)

Inputs: raw description, merchant name, MCC, amount, date, location (if any), past rules, user favorites.
Steps:

Normalize merchant (e.g., PIZZA_HUT_SQ223 → Pizza Hut).

Categorize → (parent, sub, confidence, “rule candidate?”).

Explain (short) for audit; store in ai_metadata.

Rules engine: if user toggled “remember,” persist (merchant → sub) with scope (this user; optional group scope).

Fallbacks:

If low confidence or ambiguous (“E-Transfer”), default to Misc Expense/Income (Unassigned) and enqueue.

Provide top-3 suggestions in UI chips.

Data Model (Postgres tables)
users(id, email, created_at)
profiles(user_id PK/FK, username UNIQUE, full_name, avatar_url, public_id, school, city, age, bio)

institutions(id PK, user_id, name, plaid_access_token, mask, created_at)
accounts(id PK, user_id, institution_id, official_name, type, subtype, mask, current_balance, available_balance, currency, is_credit, created_at)
webhooks(id PK, type, body_json, received_at)

categories(id PK, user_id NULLABLE (NULL = global/locked), parent_key, name, emoji, is_locked BOOL)
rules(id PK, user_id, merchant_norm, category_id, confidence_min NUMERIC, scope ENUM('user','group'), created_at)

transactions(id PK, user_id, account_id, posted_at, amount_cents, currency, raw_description, merchant_raw, merchant_norm, mcc, is_credit BOOL, ai_category_id NULL, ai_confidence NUMERIC, status ENUM('pending','posted','void'), source ENUM('plaid','manual'), created_at)

queue_items(id PK, user_id, transaction_id, queue_type ENUM('categorize','split'), state ENUM('new','reviewing','done'), created_at)

splits(id PK, user_id, transaction_id, group_id NULL, visibility ENUM('public','private'), method ENUM('equal','shares','exact'), created_at)
split_lines(id PK, split_id, party_user_id, amount_cents, note)

groups(id PK, user_id_owner, name, kind ENUM('house','family','custom'), code)
group_members(id PK, group_id, user_id)

budgets(id PK, user_id, month_yyyymm, category_id, planned_cents, rollover_policy ENUM('carry','reset'))
actuals(id PK, user_id, month_yyyymm, category_id, actual_cents)

survey_answers(id PK, user_id, key, value_json, created_at)
ai_metadata(id PK, transaction_id, normalize_rationale, categorize_rationale, model, version)

API Contracts (Edge Functions)

POST /plaid/link/token → { link_token }
POST /plaid/token/exchange { public_token } → stores access_token, returns { ok:true }
POST /plaid/webhook (server-to-server) → upsert accounts; ingest transactions; enqueue; return 200
GET /transactions?state=queue&limit=5 → next batch for + tab
POST /transactions/categorize [{transaction_id, category_id, remember?}] → apply + optional rule
POST /splits { transaction_id, group_id, method, lines[], visibility }
GET /accounts → balances for Present View
GET /budgets/:month → planned vs actual

Flutter UI Wiring Plan

Auth Screens: Supabase Auth → collect name/@username/avatar → upload to Storage.

Survey Wizard: one-prompt screens (Chips, Number steppers); write to survey_answers.

Categories Setup: parent screens with editable subchips; post to categories.

Home: Present Value card; CTA “Connect bank accounts”.

Plaid Link: Use flutter_webview/official Plaid Link SDK for Flutter (community) → receive public_token → call exchange.

Track Tab:

left: category tree (planned vs actual)

right: Real Accounts carousel (swipe balances)

Plus (+) Tab (Queue): list by day; 5-item paginator; inline chips for top-3 AI picks; “Remember” toggle; Submit.

Split Tab: table editor for shares/exact; group picker; Submit (5 at a time).

Profile: public card preview + QR for public_id.

State Machine (key app states)
STATE: AUTH_START → PROFILE_CREATED → SURVEY_FLOW → CATEGORIES_INIT → HOME_EMPTY
→ (optional) PLAID_CONNECTING → ACCOUNTS_SYNCED
→ DAILY_QUEUE_READY ↔ QUEUE_REVIEWING ↔ QUEUE_DONE
→ SPLIT_QUEUE_READY ↔ SPLIT_REVIEWING ↔ SPLIT_DONE
→ MONTH_CLOSE → (rollover) HOME_NEXT_MONTH

Privacy & Security

Read-only aggregations; never ask for bank passwords.

PII minimized; no full account numbers.

Public profile shows only @username, name, avatar, and optional school/city—never balances.

Row Level Security: user_id = auth.uid().

Secrets (Plaid, OpenAI) server-side only.

Edge Cases & Rules

E-Transfers: classify as Income: Other/Bonus or Savings/Debt: Credit card payment when recognizable; else “Misc (Unassigned)”.

Pending → Posted: update in place; keep category unless merchant changes.

Reversals/Refunds: attach negative line to original when amount ≈ -original.

Confidence < threshold: force to queue with 3 suggestions.

Rule precedence: user rule > AI guess > favorite merchant > parent default.

“Luni Orchestrator” (dev prompt for your agent)

You are the Luni Orchestrator. Given a transaction JSON with raw_description, merchant_norm, mcc, amount, date, history[], user_rules[], return:

normalized_merchant (string),

proposed_category {parent_key, sub_name},

confidence (0–1),

remember_rule (bool, default false),

alternates (up to 3),

justification (≤ 2 sentences).
Never change balances. If confidence < 0.6, add to alternates and set remember_rule=false.

Output (strict JSON, no markdown):

{
  "normalized_merchant": "Pizza Hut",
  "proposed_category": {"parent_key": "food_drink", "sub_name": "Snacks & Fast food"},
  "confidence": 0.82,
  "remember_rule": false,
  "alternates": [
    {"parent_key":"food_drink","sub_name":"Nicer Meals out"},
    {"parent_key":"personal_social","sub_name":"Entertainment"}
  ],
  "justification": "Merchant string matched prior purchases and MCC. Spend pattern aligns with fast food at this time/place."
}

Implementation Checklist

 Supabase schemas & RLS policies

 Edge Functions: link token, token exchange, webhook, queue endpoints

 OpenAI categorize/normalize functions + rule store

 Flutter: Auth → Survey → Categories → Home → Plaid Link → Track/Accounts → Plus Queue (5 at a time) → Split Queue (5 at a time)

 Present Value card & Monthly budgets (seeded from 90 days)

 Group & Split flows (public/private posts)

 Month close & rollover snapshot

 Analytics & logs (classification accuracy, queue size, rule hits)

Notes for Future Premium Gating

Move bank connection behind Premium paywall when ready; leave “manual queue import” for free tier.

Credits/Rewards can subsidize Premium via engagement (streaks, splits completed).

Developer Seed Data

Create one institution with 2 accounts (checking, credit).

Seed 50 txns (groceries, coffee, restaurants, rideshare, rent, subscriptions).

Mark 20 as queued, 30 categorized to test both tabs.

This document is the source of truth for implementing onboarding, Plaid ingestion, AI categorization, queues, splits, balances, and month close in Flutter + Supabase.