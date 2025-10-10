#!/bin/bash

# Comprehensive Plaid API Test
echo "🔍 COMPREHENSIVE PLAID API TEST"
echo "================================"
echo ""

# Load credentials from .env
cd "/Users/rorygeddes/Workspace/Vancouver/Luni Final/Luni Flutter/luni_app"
source .env

echo "📋 Configuration:"
echo "   Client ID: $PLAID_CLIENT_ID"
echo "   Environment: $PLAID_ENV"
echo "   Secret: ${PLAID_SECRET:0:10}... (hidden)"
echo ""

# Test 1: Create Link Token (Most important test)
echo "🧪 TEST 1: Creating Link Token (Required for linking banks)..."
echo "------------------------------------------------"

link_response=$(curl -s -X POST https://production.plaid.com/link/token/create \
  -H 'Content-Type: application/json' \
  -d '{
    "client_id": "'$PLAID_CLIENT_ID'",
    "secret": "'$PLAID_SECRET'",
    "client_name": "Luni",
    "user": {
      "client_user_id": "test-user-123"
    },
    "products": ["transactions"],
    "country_codes": ["CA", "US"],
    "language": "en"
  }')

echo "Response:"
echo "$link_response" | jq . 2>/dev/null || echo "$link_response"
echo ""

# Check if link token was created successfully
if echo "$link_response" | grep -q "link_token"; then
  echo "✅ TEST 1 PASSED: Link token created successfully!"
  echo "   Your API keys are WORKING and you can link banks."
else
  echo "❌ TEST 1 FAILED: Could not create link token"
  if echo "$link_response" | grep -q "invalid_api_keys"; then
    echo "   ERROR: Invalid API keys"
    echo "   ACTION NEEDED: Update your credentials from Plaid dashboard"
  elif echo "$link_response" | grep -q "INVALID_SECRET"; then
    echo "   ERROR: Invalid secret key"
    echo "   ACTION NEEDED: Regenerate your secret from Plaid dashboard"
  elif echo "$link_response" | grep -q "INVALID_CLIENT_ID"; then
    echo "   ERROR: Invalid client ID"
    echo "   ACTION NEEDED: Check your client ID from Plaid dashboard"
  else
    echo "   ERROR: Unknown error - check response above"
  fi
fi

echo ""
echo "================================================"
echo ""

# Test 2: Check API access
echo "🧪 TEST 2: Verifying API Access..."
echo "------------------------------------------------"

categories_response=$(curl -s -X POST https://production.plaid.com/categories/get \
  -H 'Content-Type: application/json' \
  -d '{
    "client_id": "'$PLAID_CLIENT_ID'",
    "secret": "'$PLAID_SECRET'"
  }')

if echo "$categories_response" | grep -q "categories"; then
  echo "✅ TEST 2 PASSED: API access confirmed"
else
  echo "❌ TEST 2 FAILED: No API access"
fi

echo ""
echo "================================================"
echo ""

# Summary
echo "📊 SUMMARY:"
echo ""
if echo "$link_response" | grep -q "link_token"; then
  echo "✅ PLAID IS WORKING CORRECTLY"
  echo "   ✓ API credentials are valid"
  echo "   ✓ Link tokens can be created"
  echo "   ✓ Ready to link bank accounts"
  echo ""
  echo "Your Plaid integration is fully functional! 🎉"
else
  echo "❌ PLAID IS NOT WORKING"
  echo "   ✗ Cannot create link tokens"
  echo "   ✗ Cannot link new banks"
  echo ""
  echo "🔧 TO FIX:"
  echo "1. Go to https://dashboard.plaid.com/"
  echo "2. Sign in to your account"
  echo "3. Go to Team Settings → Keys"
  echo "4. Copy your Production credentials:"
  echo "   - client_id"
  echo "   - secret (you may need to regenerate it)"
  echo "5. Update your .env file with the correct values"
fi

echo ""
echo "================================================"

