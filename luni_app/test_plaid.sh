#!/bin/bash

# Test Plaid API Credentials
echo "🔍 Testing Plaid API Credentials..."
echo ""

# Load credentials from .env
source .env

# Test API call to Plaid
response=$(curl -s -X POST https://production.plaid.com/item/get \
  -H 'Content-Type: application/json' \
  -d '{
    "client_id": "'$PLAID_CLIENT_ID'",
    "secret": "'$PLAID_SECRET'",
    "access_token": "test_token"
  }')

echo "Response from Plaid:"
echo "$response" | jq . 2>/dev/null || echo "$response"

# Check if credentials are valid
if echo "$response" | grep -q "invalid_api_keys"; then
  echo ""
  echo "❌ ERROR: Invalid API keys!"
  echo "Your Plaid credentials are incorrect or expired."
  echo ""
  echo "📝 To fix:"
  echo "1. Go to https://dashboard.plaid.com/"
  echo "2. Navigate to Team Settings → Keys"
  echo "3. Copy your Production client_id and secret"
  echo "4. Update your .env file"
elif echo "$response" | grep -q "INVALID_ACCESS_TOKEN"; then
  echo ""
  echo "✅ SUCCESS: Plaid credentials are valid!"
  echo "Your API keys are working correctly."
else
  echo ""
  echo "⚠️  Unexpected response. Please check manually."
fi

