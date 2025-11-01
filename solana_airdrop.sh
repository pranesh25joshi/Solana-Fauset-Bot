#!/bin/bash

# Solana Devnet Faucet Automation Script
# Based on official Solana CLI documentation: https://docs.anza.xyz/cli/usage

# Set the wallet address
WALLET_ADDRESS="9cV3D54tgGDxwXZeKUPt634diseVQETo56HoHejy6tAA"

# Devnet RPC endpoint
DEVNET_URL="https://api.devnet.solana.com"

# Print starting message
echo "========================================="
echo "Solana Devnet Faucet Request"
echo "========================================="
echo "Wallet: $WALLET_ADDRESS"
echo "Network: Devnet"
echo "========================================="

# Ensure solana CLI is available
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# Verify Solana CLI is available
if ! command -v solana &> /dev/null; then
    echo "❌ Error: Solana CLI not found in PATH"
    exit 1
fi

# Get initial balance
echo "📊 Checking current balance..."
INITIAL_BALANCE=$(solana balance $WALLET_ADDRESS --url $DEVNET_URL | awk '{print $1}')
echo "Initial balance: $INITIAL_BALANCE SOL"

# Request airdrop - single attempt with 1 SOL
# Solana devnet has rate limits to prevent abuse
AIRDROP_AMOUNT=1
AIRDROP_SUCCESS=false

echo ""
echo "🪂 Requesting $AIRDROP_AMOUNT SOL from devnet faucet..."

# The --url flag specifies which network to use
# According to Solana docs, airdrop is only available on devnet/testnet
if solana airdrop $AIRDROP_AMOUNT $WALLET_ADDRESS --url $DEVNET_URL 2>&1; then
  echo "✅ Successfully requested $AIRDROP_AMOUNT SOL"
  AIRDROP_SUCCESS=true
else
  echo "⚠️  Airdrop failed - possibly rate limited"
fi

if [ "$AIRDROP_SUCCESS" = false ]; then
  echo ""
  echo "========================================="
  echo "⚠️  All Airdrop Attempts Failed"
  echo "========================================="
  echo "Reason: Solana devnet has strict rate limits"
  echo "Current balance: $INITIAL_BALANCE SOL"
  echo ""
  echo "📌 Rate Limit Information:"
  echo "  - Devnet airdrops are limited to prevent abuse"
  echo "  - Typical limit: ~5 SOL per day per address"
  echo "  - Your address already has $INITIAL_BALANCE SOL"
  echo ""
  echo "💡 Next Steps:"
  echo "  1. Wait for rate limit reset (usually 24 hours)"
  echo "  2. Try again on next scheduled run"
  echo "  3. Use existing balance for testing"
  echo "========================================="
  exit 0  # Exit successfully to avoid failing GitHub Actions
fi

# Wait for transaction confirmation
echo ""
echo "⏳ Waiting for transaction confirmation..."
sleep 5

# Check new balance
echo "📊 Checking new balance..."
NEW_BALANCE=$(solana balance $WALLET_ADDRESS --url $DEVNET_URL | awk '{print $1}')
echo "New balance: $NEW_BALANCE SOL"

# Calculate the difference using awk
DIFF=$(awk -v new="$NEW_BALANCE" -v old="$INITIAL_BALANCE" 'BEGIN {print new - old}')
IS_GREATER=$(awk -v new="$NEW_BALANCE" -v old="$INITIAL_BALANCE" 'BEGIN {print (new > old) ? "yes" : "no"}')

echo ""
echo "========================================="
if [ "$IS_GREATER" = "yes" ]; then
  echo "✅ Airdrop Successful!"
  echo "========================================="
  echo "Amount received: $DIFF SOL"
  echo "Total balance: $NEW_BALANCE SOL"
  echo ""
  echo "📊 Account Summary:"
  echo "  - Initial: $INITIAL_BALANCE SOL"
  echo "  - Received: +$DIFF SOL"
  echo "  - Current: $NEW_BALANCE SOL"
  echo "========================================="
  exit 0
else
  echo "⚠️  Balance Unchanged"
  echo "========================================="
  echo "Initial: $INITIAL_BALANCE SOL"
  echo "Current: $NEW_BALANCE SOL"
  echo ""
  echo "This may occur due to:"
  echo "  - Network delays in processing"
  echo "  - Transaction confirmation pending"
  echo "  - Rate limit already applied"
  echo ""
  echo "Check balance again in a few minutes using:"
  echo "  solana balance $WALLET_ADDRESS --url $DEVNET_URL"
  echo "========================================="
  exit 0  # Don't fail the action
fi
