pls() {
  local piped_input=""
  # Read piped input if available
  if [ ! -t 0 ]; then
    piped_input=$(command cat)
  fi

  # If neither an argument nor piped input is provided, show usage.
  if [ -z "$1" ] && [ -z "$piped_input" ]; then
    echo "Usage: pls <your natural language request>"
    return 1
  fi

  local INPUT="$*"
  local TEMPLATE=""
  
  # If there's piped context, include it in the template.
  if [ -n "$piped_input" ]; then
    # Stringify the piped input for JSON compatibility
    piped_input=$(echo "$piped_input" | jq -Rs .)
    TEMPLATE="Request: $INPUT\nGenerate raw shell command only, no sudo prefix, no markdown/formatting, no comments, no explanations, no new lines. Using zsh on a macos machine.\nContext: $piped_input"
  else
    TEMPLATE="Request: $INPUT\nGenerate raw shell command only, no sudo prefix, no markdown/formatting, no comments, no explanations, no new lines. Using zsh on a macos machine."
  fi

  # Escape special characters in the template for JSON
  TEMPLATE=$(echo "$TEMPLATE" | jq -Rs .)

  # Make the API request
  local RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
    -H 'Content-Type: application/json' \
    -X POST \
    -d '{
      "contents": [{
        "parts":[{"text": '"$TEMPLATE"'}]
      }]
    }')

  # Check if the response contains an error
  if printf '%s' "$RESPONSE" | jq -e '.error' > /dev/null; then
    echo "Error from Gemini API:"
    printf '%s' "$RESPONSE" | jq -r '.error.message'
    return 1
  fi

  # Parse the response and extract the generated text
  local PARSED_RESPONSE=$(printf '%s' "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')

  # Print the parsed response to the command line
  print -z "$PARSED_RESPONSE"
}
