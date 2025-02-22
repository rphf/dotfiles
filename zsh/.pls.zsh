pls() {
  local piped_input=""
  # Read piped input if available
  if [ ! -t 0 ]; then
    piped_input=$(cat)
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
    TEMPLATE="Request: $INPUT \n Generate raw shell command only, no sudo prefix, no markdown/formatting, no comments, no explanations. Using zsh on a macos machine. \n Context: $piped_input"
  else
    TEMPLATE="Request: $INPUT \n Generate raw shell command only, no sudo prefix, no markdown/formatting, no comments, no explanations. Using zsh on a macos machine."
  fi

  local RESPONSE=$(ollama run deepseek-coder-v2 "$TEMPLATE")
  
  # Remove markdown formatting and trim excess whitespace/newlines.
  local CLEAN_RESPONSE=$(echo "$RESPONSE" |
    sed -E 's/```(bash|sh)?//g; s/```//g' |
    sed '/./,$!d' |
    sed 's/[[:space:]]*$//')

  print -z "$CLEAN_RESPONSE"
}
