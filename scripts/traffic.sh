#!/usr/bin/env bash
# This script generates traffic to the web application by sending HTTP requests in a loop.

URL="${1:-http://localhost:8080}"  # Default URL if not provided as an argument
INTERVAL="${2:-0.2}"  # Interval between requests in seconds
TIMEOUT=5  # Give up on a request after this many seconds, so a hung request can't freeze the loop

while true; do
    # Send a request to the URL and discard the output.
    # Prints: time, HTTP status (000 = no response), duration, curl exit code (0 = OK), error message if any
    curl -s -o /dev/null --max-time "$TIMEOUT" \
        -w "$(date +%T) %{http_code} %{time_total}s %{exitcode} %{errormsg}\n" "$URL"
    sleep "$INTERVAL"  # Wait for the specified interval before sending the next request
done
