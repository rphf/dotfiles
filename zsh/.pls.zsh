#!/usr/bin/env zsh
# ~/.pls.zsh - A CLI tool for generating commands, explaining commands, and creating git commits using AI

# Configuration variables
typeset -g PLS_VERSION="1.0.0"
typeset -g PLS_VERBOSE=false

# This is the only function that will be publicly available
pls() {
  
  # Define all helper functions locally within pls
  # These functions will only be available inside pls
  local _check_dependencies _log_verbose _make_api_request
  local _cmd_explain _cmd_commit _cmd_generate _show_help _show_version
  
  # Check for required dependencies
  function _check_dependencies() {
    local missing_deps=()
    
    for dep in curl jq bat; do
      if ! command -v "$dep" &> /dev/null; then
        missing_deps+=("$dep")
      fi
    done
    
    if [[ -z "$GEMINI_API_KEY" ]]; then
      echo "Error: GEMINI_API_KEY environment variable is not set."
      echo "Please set it in your .zshrc or .zshenv file:"
      echo "export GEMINI_API_KEY=\"your-api-key\""
      return 1
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
      echo "Error: The following dependencies are missing: ${missing_deps[*]}"
      echo "Please install them using your package manager."
      return 1
    fi
    
    return 0
  }

  # Log message if verbose mode is enabled
  function _log_verbose() {
    if [[ "$PLS_VERBOSE" == true ]]; then
      echo "[PLS] $*" >&2
    fi
  }

  # Make API request to Gemini
  function _make_api_request() {
    local template="$1"
    local escaped_template=$(echo "$template" | jq -Rs .)
    
    _log_verbose "Sending request to Gemini API..."
    _log_verbose "PROMPT:\n$template"
    
    local response=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
      -H 'Content-Type: application/json' \
      -X POST \
      -d '{
        "contents": [{
          "parts":[{"text": '"$escaped_template"'}]
        }]
      }')
    
    # Check if the response contains an error
    if printf '%s' "$response" | jq -e '.error' > /dev/null; then
      echo "Error from Gemini API:"
      printf '%s' "$response" | jq -r '.error.message'
      return 1
    fi
    
    # Parse the response and extract the generated text
    printf '%s' "$response" | jq -r '.candidates[0].content.parts[0].text'
    return 0
  }

  # Command to explain shell commands
  function _cmd_explain() {
    if [[ -z "$1" ]]; then
      echo "Usage: pls explain <command>"
      return 1
    fi
    
    local cmd_to_explain="$*"
    local template="Request: Explain the following command: $cmd_to_explain\nProvide a concise description of what it does. Do not provide examples or usage instructions. Provide a safety level"
    
    _log_verbose "Explaining command: $cmd_to_explain"
    
    local response=$(_make_api_request "$template")
    if [[ $? -ne 0 ]]; then
      return 1
    fi
    
    echo "$response" | bat --language=md --paging=never
    return 0
  }

  # Command to generate git commit messages
  function _cmd_commit() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      echo "Error: Not in a git repository."
      return 1
    fi
    
    local diff=$(git diff --staged)
    if [[ -z "$diff" ]]; then
      echo "Error: No staged changes found. Use 'git add' to stage changes first."
      return 1
    fi
    
    local repo_root=$(git rev-parse --show-toplevel)
    local commit_rules=""
    if [[ -f "$repo_root/commit-rules.txt" ]]; then
      commit_rules=$(cat "$repo_root/commit-rules.txt")
      _log_verbose "Found commit rules file at $repo_root/commit-rules.txt"
    fi
    
    # Extract additional instructions if provided
    local additional_instruction=""
    if [[ $# -gt 0 ]]; then
      additional_instruction="$*"
      _log_verbose "Additional commit instructions: $additional_instruction"
    fi
    
    local template="Generate a git commit message based on the following staged changes, commit rules, and additional instructions. The commit message must strictly follow the rules if provided. Don't add any special characters or quotes in the commit message. Only respond with the raw git commit command in the format 'git commit -m \"...\"', no markdown/formatting.\n\nCommit rules:\n$commit_rules\n\nAdditional instructions:\n$additional_instruction\n\nStaged changes:\n$diff"
    
    _log_verbose "Generating git commit message..."
    
    local response=$(_make_api_request "$template")
    if [[ $? -ne 0 ]]; then
      return 1
    fi
    
    if [[ "$response" =~ ^git\ commit\ -m\ \".*\"$ ]]; then
      print -z "$response"
      _log_verbose "Successfully generated commit command"
    else
      echo "Error: Generated invalid commit command:"
      echo "$response"
      return 1
    fi
    
    return 0
  }

  # Command to generate shell commands
  function _cmd_generate() {
    local piped_input=""
    # Read piped input if available
    if [[ ! -t 0 ]]; then
      piped_input=$(cat)
      _log_verbose "Received piped input"
    fi
    
    if [[ -z "$1" && -z "$piped_input" ]]; then
      echo "Usage: pls <your natural language request>"
      return 1
    fi
    
    local input="$*"
    local template=""
    
    # If there's piped context, include it in the template
    if [[ -n "$piped_input" ]]; then
      template="Request: $input\nGenerate raw shell command only, no sudo prefix, no markdown/formatting, no comments, no explanations, no new lines. Using zsh on a macos machine.\nContext: $piped_input"
    else
      template="Request: $input\nGenerate raw shell command only, no sudo prefix, no markdown/formatting, no comments, no explanations, no new lines. Using zsh on a macos machine."
    fi
    
    _log_verbose "Generating command for: $input"
    
    local response=$(_make_api_request "$template")
    if [[ $? -ne 0 ]]; then
      return 1
    fi
    
    print -z "$response"
    _log_verbose "Command generated and loaded into buffer"
    return 0
  }

  # Display help information
  function _show_help() {
    cat << EOF
pls - CLI tool for generating and explaining shell commands using AI

Usage:
  pls [options] <request>           Generate a shell command
  pls e|explain [options] <command> Explain a shell command
  pls c|commit [options] [message]  Generate a git commit message

Options:
  -h, --help     Show this help message
  -v, --verbose  Enable verbose output
  --version      Show version information

Examples:
  pls find all png files larger than 1MB
  pls explain tar -xzf archive.tar.gz
  pls commit fix login button functionality
  ls -la | pls convert to csv format
EOF
  }

  # Show version information
  function _show_version() {
    echo "pls v$PLS_VERSION"
  }

  # MAIN FUNCTION LOGIC STARTS HERE
  
  # Check dependencies first
  _check_dependencies || return 1
  
  # No arguments provided
  if [[ $# -eq 0 && -t 0 ]]; then
    _show_help
    return 0
  fi
  
  # Parse options
  while [[ "$1" =~ ^- ]]; do
    case "$1" in
      -h|--help)
        _show_help
        return 0
        ;;
      -v|--verbose)
        PLS_VERBOSE=true
        _log_verbose "Verbose mode enabled"
        shift
        ;;
      --version)
        _show_version
        return 0
        ;;
      *)
        echo "Unknown option: $1"
        echo "Use 'pls --help' to see available options."
        return 1
        ;;
    esac
  done
  
  # No more arguments
  if [[ $# -eq 0 && -t 0 ]]; then
    _show_help
    return 0
  fi
  
  # Dispatch to subcommands
  case "$1" in
    e|explain)
      shift
      _cmd_explain "$@"
      ;;
    c|commit)
      shift
      _cmd_commit "$@"
      ;;
    *)
      _cmd_generate "$@"
      ;;
  esac
}

