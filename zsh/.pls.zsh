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

  # Handle 'explain' command
  if [ "$1" = "e" ] || [ "$1" = "explain" ]; then
    shift
    local CMD_TO_EXPLAIN="$*"
    local TEMPLATE="Request: Explain the following command: $CMD_TO_EXPLAIN\nProvide a concise description of what it does. Do not provide examples or usage instructions. Provide a safety level"
    TEMPLATE=$(echo -e "$TEMPLATE" | jq -Rs .)
    
    local RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
      -H 'Content-Type: application/json' \
      -X POST \
      -d '{
        "contents": [{
          "parts":[{"text": '"$TEMPLATE"'}]
        }]
      }')
    
    if printf '%s' "$RESPONSE" | jq -e '.error' > /dev/null; then
      echo "Error from Gemini API:"
      printf '%s' "$RESPONSE" | jq -r '.error.message'
      return 1
    fi
    
    local PARSED_RESPONSE=$(printf '%s' "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')
    echo "$PARSED_RESPONSE" | bat --language=md --paging=never
    return 0
  fi

  # Handle 'commit' command
  if [ "$1" = "c" ] || [ "$1" = "commit" ]; then
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      echo "Not in a git repository."
      return 1
    fi

    local DIFF=$(git diff --staged)
    local REPO_ROOT=$(git rev-parse --show-toplevel)
    local COMMIT_RULES=""
    if [ -f "$REPO_ROOT/commit-rules.txt" ]; then
      COMMIT_RULES=$(cat "$REPO_ROOT/commit-rules.txt")
    fi

    # Extract additional instructions if provided
    local ADDITIONAL_INSTRUCTION=""
    if [ $# -gt 1 ]; then
      shift
      ADDITIONAL_INSTRUCTION="$*"
    fi

    local TEMPLATE="Generate a git commit message based on the following staged changes, commit rules, and additional instructions. The commit message must strictly follow the rules if provided. Only respond with the raw git commit command in the format 'git commit -m \"...\"', no markdown/formatting.\n\nCommit rules:\n$COMMIT_RULES\n\nAdditional instructions:\n$ADDITIONAL_INSTRUCTION\n\nStaged changes:\n$DIFF"
    TEMPLATE=$(echo -e "$TEMPLATE" | jq -Rs .)

    echo "$TEMPLATE" | bat --language=md --paging=never
    
    local RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
      -H 'Content-Type: application/json' \
      -X POST \
      -d '{
        "contents": [{
          "parts":[{"text": '"$TEMPLATE"'}]
        }]
      }')
    
    if printf '%s' "$RESPONSE" | jq -e '.error' > /dev/null; then
      echo "Error from Gemini API:"
      printf '%s' "$RESPONSE" | jq -r '.error.message'
      return 1
    fi
    
    local PARSED_RESPONSE=$(printf '%s' "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')
    
    if [[ "$PARSED_RESPONSE" =~ ^git\ commit\ -m\ \".*\"$ ]]; then
      print -z "$PARSED_RESPONSE"
    else
      echo "Generated invalid commit command:"
      echo "$PARSED_RESPONSE"
      return 1
    fi
    return 0
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
