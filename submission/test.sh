#!/bin/bash

# Capstone Exercise: Bitcoin Address Generation and Transaction Verification
# This script demonstrates using the key concepts from previous exercises in a practical scenario

# Ensure script fails fast on errors
set -e

# ========================================================================
# HELPER FUNCTIONS (PROVIDED - you don't need to modify these)
# ========================================================================

# Helper function to format JSON output
format_json() {
  # This uses jq if available, otherwise falls back to a simple echo
  if command -v jq &> /dev/null; then
    echo "$1" | jq .
  else
    echo "$1"
  fi
}

# Helper function to mine some blocks and get coins (not part of the exercises)
mine_blocks() {
  local num_blocks=$1
  local address=$2
  echo "Generating $num_blocks blocks to $address..."
  result=$(bitcoin-cli -regtest generatetoaddress $num_blocks $address)
  echo "Mined blocks: $(echo $result | tr -d '[]"' | cut -c 1-10)... (truncated)"
  # Wait a moment for blocks to be processed
  sleep 1
}

# Helper function to show formatted wallet info
show_wallet_info() {
  local wallet=$1
  echo "=============== WALLET INFO for $wallet ==============="
  info=$(bitcoin-cli -regtest -rpcwallet=$wallet getwalletinfo)
  echo "Balance: $(echo $info | grep -o '"balance":[^,]*' | cut -d':' -f2) BTC"
  echo "TX Count: $(echo $info | grep -o '"txcount":[^,]*' | cut -d':' -f2)"
  echo "======================================================="
}

# Helper function to prepare the challenge scenario
setup_challenge() {
  echo "Setting up scenario: A Bitcoin treasure hunt..."
  echo "You've found a series of clues that lead to hidden bitcoin funds."
  echo "Each clue will require you to use Bitcoin Core commands to reveal the next step."
  echo "First, you'll need to create a wallet to track your discoveries."
  echo ""
}

# Helper function to check for command success
check_cmd() {
  if [ $? -ne 0 ]; then
    echo "ERROR: $1 command failed!"
    exit 1
  fi
}

# Helper function to safely ensure a wallet is available
ensure_wallet_available() {
  local wallet_name=$1
  local is_watch_only=$2

  # First check if the wallet is already in the list of loaded wallets
  if bitcoin-cli -regtest listwallets | grep -q "\"$wallet_name\""; then
    echo "Wallet '$wallet_name' is already loaded."
    return 0
  fi

  # Try to load the wallet
  if bitcoin-cli -regtest loadwallet "$wallet_name" 2>/dev/null; then
    echo "Loaded existing wallet '$wallet_name'."
    return 0
  fi

  # If loading failed, create the wallet
  echo "Creating new wallet '$wallet_name'..."
  if [ "$is_watch_only" = "true" ]; then
    bitcoin-cli -regtest createwallet "$wallet_name" true false "" false false
  else
    bitcoin-cli -regtest createwallet "$wallet_name"
  fi

  if [ $? -eq 0 ]; then
    echo "Successfully created wallet '$wallet_name'."
    return 0
  else
    echo "ERROR: Failed to create wallet '$wallet_name'!"
    return 1
  fi
}

# Helper function to send funds with explicit fee handling for regtest
send_with_fee() {
  local from_wallet=$1
  local to_address=$2
  local amount=$3
  local comment=$4
  
  echo "Sending $amount BTC from $from_wallet to $to_address..."
  
  # Use settxfee to set a reasonable fee for regtest
  bitcoin-cli -regtest -rpcwallet=$from_wallet settxfee 0.00001
  check_cmd "Setting transaction fee"
  
  # Send the transaction
  local txid=$(bitcoin-cli -regtest -rpcwallet=$from_wallet sendtoaddress "$to_address" "$amount" "$comment")
  check_cmd "Sending transaction"
  
  echo "Transaction sent! TXID: ${txid:0:16}... (truncated)"
  return 0
}

# Helper function to trim whitespace from strings
trim() {
  local var="$*"
  # Remove leading whitespace
  var="${var#"${var%%[![:space:]]*}"}"
  # Remove trailing whitespace
  var="${var%"${var##*[![:space:]]}"}"
  printf '%s' "$var"
}

# ========================================================================
# STUDENT EXERCISE PART BEGINS HERE - Complete the following sections
# ========================================================================

# Set up the challenge scenario
setup_challenge

# CHALLENGE PART 1: Create a wallet to track your discoveries
echo "CHALLENGE 1: Create your explorer wallet"
echo "----------------------------------------"
echo "Create a wallet named 'btrustwallet' to track your Bitcoin exploration"
# STUDENT TASK: Use bitcoin-cli to create a wallet named "btrustwallet"
# WRITE YOUR SOLUTION BELOW:


# Create a second wallet that will hold the treasure
echo "Now, create another wallet called 'treasurewallet' to fund your adventure"
# STUDENT TASK: Create another wallet called "treasurewallet"
# WRITE YOUR SOLUTION BELOW:


# Generate an address for mining in the treasure wallet
# STUDENT TASK: Generate a new address in the treasurewallet
# WRITE YOUR SOLUTION BELOW:
TREASURE_ADDR=
check_cmd "Address generation"
echo "Mining to address: $TREASURE_ADDR"

# Mine some blocks to get initial coins
mine_blocks 101 $TREASURE_ADDR

# CHALLENGE PART 2: Check your starting balance 
echo ""
echo "CHALLENGE 2: Check your starting resources"
echo "-----------------------------------------"
echo "Check your wallet balance to see what resources you have to start"
# STUDENT TASK: Get the balance of btrustwallet
# WRITE YOUR SOLUTION BELOW:
BALANCE=
check_cmd "Balance check"
echo "Your starting balance: $BALANCE BTC"

# CHALLENGE PART 3: Generate different address types to collect treasures
echo ""
echo "CHALLENGE 3: Create a set of addresses for your exploration"
echo "---------------------------------------------------------"
echo "The treasure hunt requires 4 different types of addresses to collect funds."
echo "Generate one of each address type (legacy, p2sh-segwit, bech32, bech32m)"
# STUDENT TASK: Generate addresses of each type
# WRITE YOUR SOLUTION BELOW:
LEGACY_ADDR=
check_cmd "Legacy address generation"

P2SH_ADDR=
check_cmd "P2SH address generation"

SEGWIT_ADDR=
check_cmd "SegWit address generation"

TAPROOT_ADDR=
check_cmd "Taproot address generation"

echo "Your exploration addresses:"
echo "- Legacy treasure map: $LEGACY_ADDR"
echo "- P2SH ancient vault: $P2SH_ADDR"
echo "- SegWit digital safe: $SEGWIT_ADDR"
echo "- Taproot quantum vault: $TAPROOT_ADDR"

# This part is done for you - sending treasures to each address
echo ""
echo "The treasure hunt begins! Coins are being sent to your addresses..."

# Send treasure to each address using our helper function with fee handling
send_with_fee "treasurewallet" "$LEGACY_ADDR" 1.0 "First clue: Verify this transaction"
send_with_fee "treasurewallet" "$P2SH_ADDR" 2.0 "Second clue: Needs validation" 
send_with_fee "treasurewallet" "$SEGWIT_ADDR" 3.0 "Third clue: Check descriptor"
send_with_fee "treasurewallet" "$TAPROOT_ADDR" 4.0 "Final clue: Message verification"

# Mine blocks to confirm the transactions
mine_blocks 6 $TREASURE_ADDR

# CHALLENGE PART 4: Find the total treasure collected
echo ""
echo "CHALLENGE 4: Count your treasures"
echo "-------------------------------"
echo "Treasures have been sent to your addresses. Check how much you've collected!"
# STUDENT TASK: Check wallet balance after receiving funds and calculate how much treasure was collected
# WRITE YOUR SOLUTION BELOW:
NEW_BALANCE=
check_cmd "New balance check"
echo "Your treasure balance: $NEW_BALANCE BTC"

COLLECTED=
check_cmd "Balance calculation"
echo "You've collected $COLLECTED BTC in treasures!"

# CHALLENGE PART 5: Verify that one of your addresses is valid
echo ""
echo "CHALLENGE 5: Validate the ancient vault address"
echo "--------------------------------------------"
echo "To ensure the P2SH vault is secure, verify it's a valid Bitcoin address"
# STUDENT TASK: Validate the P2SH address
# WRITE YOUR SOLUTION BELOW:
P2SH_VALID=
check_cmd "Address validation"
echo "P2SH vault validation: $P2SH_VALID"

if [[ "$P2SH_VALID" == "true" ]]; then
  echo "Vault is secure! You may proceed to the next challenge."
else
  echo "WARNING: Vault security compromised!"
  exit 1
fi

# CHALLENGE PART 6: Decode a signed message to reveal a secret
echo ""
echo "CHALLENGE 6: Decode the hidden message"
echo "------------------------------------"
echo "You've found a message signed with the legacy address key."
echo "Verify the signature to reveal the hidden message!"

# This part is done for you - creating a signed message
SECRET_MESSAGE="You've successfully completed the Bitcoin treasure hunt!"
SIGNATURE=$(bitcoin-cli -regtest -rpcwallet=btrustwallet signmessage $LEGACY_ADDR "$SECRET_MESSAGE")
check_cmd "Message signing"
echo "Address: $LEGACY_ADDR"
echo "Signature: $SIGNATURE"

# For interactive learning, students would guess the message:
echo "In an interactive environment, you would guess the message content."
echo "For CI testing, we'll verify the correct message directly:"

# STUDENT TASK: Verify the message
# WRITE YOUR SOLUTION BELOW:
VERIFY_RESULT=
check_cmd "Message verification"
echo "Message verification result: $VERIFY_RESULT"

if [[ "$VERIFY_RESULT" == "true" ]]; then
  echo "Message verified successfully! The secret message is:"
  echo "\"$SECRET_MESSAGE\""
else
  echo "ERROR: Message verification failed!"
  exit 1
fi

# CHALLENGE PART 7: Working with descriptors to find the final treasure
echo ""
echo "CHALLENGE 7: The descriptor treasure map"
echo "-------------------------------------"
echo "The final treasure is locked with an address derived from a descriptor."
echo "Create a descriptor for your taproot address and derive the address to ensure it matches."

# STUDENT TASK: Create a new taproot address
# WRITE YOUR SOLUTION BELOW:
NEW_TAPROOT_ADDR=
check_cmd "New taproot address generation"
NEW_TAPROOT_ADDR=$(trim "$NEW_TAPROOT_ADDR")

# STUDENT TASK: Get the address info to extract the internal key
# WRITE YOUR SOLUTION BELOW:
ADDR_INFO=
check_cmd "Getting address info"

# STUDENT TASK: Extract the internal key (the x-only pubkey) from the descriptor
# WRITE YOUR SOLUTION BELOW:
INTERNAL_KEY=
check_cmd "Extracting key from descriptor"
INTERNAL_KEY=$(trim "$INTERNAL_KEY")

# STUDENT TASK: Create a proper descriptor with just the key
# WRITE YOUR SOLUTION BELOW:
echo "Using internal key: $INTERNAL_KEY"
SIMPLE_DESCRIPTOR=
echo "Simple descriptor: $SIMPLE_DESCRIPTOR"

# STUDENT TASK: Get a proper descriptor with checksum
# WRITE YOUR SOLUTION BELOW:
TAPROOT_DESCRIPTOR=
check_cmd "Descriptor generation"
TAPROOT_DESCRIPTOR=$(trim "$TAPROOT_DESCRIPTOR")
echo "Taproot treasure map: $TAPROOT_DESCRIPTOR"

# STUDENT TASK: Derive an address from the descriptor
# WRITE YOUR SOLUTION BELOW:
DERIVED_ADDR_RAW=
check_cmd "Address derivation"
DERIVED_ADDR=$(echo "$DERIVED_ADDR_RAW" | tr -d '[]" \n\t')
echo "Derived quantum vault address: $DERIVED_ADDR"

# Verify the addresses match
echo "New taproot address: $NEW_TAPROOT_ADDR"
echo "Derived address:     $DERIVED_ADDR"

# Debug output to help diagnose any issues
echo "Address lengths: ${#NEW_TAPROOT_ADDR} vs ${#DERIVED_ADDR}"
echo "Address comparison (base64 encoded to see any hidden characters):"
echo "New:     $(echo -n "$NEW_TAPROOT_ADDR" | base64)"
echo "Derived: $(echo -n "$DERIVED_ADDR" | base64)"

if [[ "$NEW_TAPROOT_ADDR" == "$DERIVED_ADDR" ]]; then
  echo "Addresses match! The final treasure is yours!"
  
  # For educational purposes, show both addresses from the challenge
  echo ""
  echo "Note: In Bitcoin Core v28, the original taproot address used in the challenge was:"
  echo "Original address: $TAPROOT_ADDR"
  echo "This wasn't used in our final verification to ensure consistency with v28."
else
  echo "ERROR: Address mismatch detected! The derived address does not match the taproot address."
  echo "This indicates an issue with the descriptor derivation process."
  echo "New taproot address: $NEW_TAPROOT_ADDR"
  echo "Derived address:     $DERIVED_ADDR"
  exit 1
fi

# CHALLENGE COMPLETE
echo ""
echo "TREASURE HUNT COMPLETE!"
echo "======================="
show_wallet_info "btrustwallet"
echo ""
echo "Congratulations on completing the Bitcoin treasure hunt!"
echo "You've successfully used Bitcoin Core to:"
echo "- Create a wallet"
echo "- Generate different address types"
echo "- Track and verify balances"
echo "- Validate addresses"
echo "- Work with message signatures"
echo "- Use Bitcoin descriptors"
echo ""
echo "NOTE: This script is specifically designed to work with Bitcoin Core v28." 
