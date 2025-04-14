#!/bin/bash

# Set the wallet address
WALLET_ADDRESS="9cV3D54tgGDxwXZeKUPt634diseVQETo56HoHejy6tAA"

# Print starting message
echo "Requesting SOL airdrop for wallet: $WALLET_ADDRESS"

# Ensure solana CLI is available
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# Get initial balance
INITIAL_BALANCE=$(solana balance $WALLET_ADDRESS --url https://api.devnet.solana.com | awk '{print $1}')
echo "Initial balance: $INITIAL_BALANCE SOL"

# Request 5 SOL from devnet
echo "Requesting airdrop..."
solana airdrop 5 $WALLET_ADDRESS --url https://api.devnet.solana.com

# Wait for transaction to confirm
sleep 5

# Confirm new balance
NEW_BALANCE=$(solana balance $WALLET_ADDRESS --url https://api.devnet.solana.com | awk '{print $1}')
echo "New balance: $NEW_BALANCE SOL"

# Calculate the difference
if (( $(echo "$NEW_BALANCE > $INITIAL_BALANCE" | bc -l) )); then
  echo "Airdrop successful! Received $(echo "$NEW_BALANCE - $INITIAL_BALANCE" | bc -l) SOL"
  exit 0
else
  echo "Airdrop may have failed. Balance did not increase."
  exit 1
fi
