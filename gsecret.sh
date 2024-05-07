#!/bin/bash

get_current_project() {
  gcloud config get-value project 2>/dev/null
}

list_secrets() {
  local project="$1"
  if [ -z "$project" ]; then
    project=$(get_current_project)
  fi

  if [ -z "$project" ]; then
    echo "No project ID found. Please specify the project ID using --project or set the current project using 'gcloud config set project <PROJECT_ID>'."
    exit 1
  fi

  gcloud secrets list --project="$project" --format="value(NAME)"
}

get_secret() {
  local project="$1"
  local secret_id="$2"
  local payload
  if [ -z "$project" ]; then
    project=$(get_current_project)
  fi

  if [ -z "$project" ]; then
    echo "No project ID found. Please specify the project ID using --project or set the current project using 'gcloud config set project <PROJECT_ID>'."
    exit 1
  fi

  payload=$(gcloud secrets versions access latest --secret="$secret_id" --project="$project" --format="value(payload.data)")

  echo "$payload"
}

apply_secrets() {
  local project="$1"
  local secrets=$(list_secrets "$project")
  local secret
  for secret in $secrets; do
    local value=$(get_secret "$project" "$secret")
    export "$secret"="$value"
  done
  echo "Secrets applied for current shell."
}

save_secret_to_env() {
  local project="$1"
  local secret_id="$2"
  local value=$(get_secret "$project" "$secret_id")

  # Parse JSON value into .env format
  local formatted_secret=""
  while IFS= read -r line; do
    local key=$(echo "$line" | cut -d ':' -f 1 | tr -d '" ')
    local val=$(echo "$line" | cut -d ':' -f 2- | tr -d '" ')
    formatted_secret+="$key=$val"$'\n'
  done < <(echo "$value" | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")

  echo "$formatted_secret"
}

save_secret_to_file() {
  local secret_id="$1"
  local formatted_secret="$2"
  local filename="$secret_id.env"
  echo "$formatted_secret" > "$filename"
  echo "Secret '$secret_id' saved to '$filename'."
}

save_secrets() {
  local project="$1"
  local secret_id="$2"

  if [ -z "$secret_id" ]; then
    echo "Secret name must be specified for --save action."
    exit 1
  fi

  if [ -n "$project" ]; then
    local formatted_secret=$(save_secret_to_env "$project" "$secret_id")
    save_secret_to_file "$secret_id" "$formatted_secret"
    local secret_count=$(echo "$formatted_secret" | grep -c '=')
    echo "Total $secret_count secrets saved."
  else
    echo "No project ID found. Please specify the project ID using --project or set the current project using 'gcloud config set project <PROJECT_ID>'."
    exit 1
  fi
}


show_help() {
  echo "Usage: $0 [--project PROJECT_ID] [--list | --apply SECRET_NAME | --save SECRET_NAME] [--format FORMAT] [--change-project]"
  echo "Options:"
  echo "  --project PROJECT_ID   Set the Google Cloud project ID."
  echo "  --list                 List all available secrets."
  echo "  --apply SECRET_NAME    Apply the specified secret to the current shell."
  echo "  --save SECRET_NAME     Save the specified secret to a .env file."
  echo "  --format FORMAT        Specify the output format for --apply and --save options. Default is 'json'."
  echo "  --change-project       Change the Google Cloud project ID interactively."
  exit 1
}

main() {
  local project=""
  local action="get"
  local format="json"
  local secret_id=""

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --project)
        project="$2"
        shift 2
        ;;
      --list)
        action="list"
        shift
        ;;
      --apply)
        action="apply"
        shift
        ;;
      --save)
        action="save"
        shift
        ;;
      --format)
        format="$2"
        shift 2
        ;;
      --change-project)
        project=""
        shift
        ;;
      *)
        secret_id="$1"
        shift
        ;;
    esac
  done

  if [ -z "$project" ]; then
    project=$(get_current_project)
  fi

  if [ -z "$project" ]; then
    echo "No project ID found. Please specify the project ID using --project or set the current project using 'gcloud config set project <PROJECT_ID>'."
    exit 1
  fi

  if [ -z "$secret_id" ]; then
    show_help
    exit 1
  fi

  if [ "$action" = "list" ]; then
    list_secrets "$project"
  elif [ "$action" = "apply" ]; then
    apply_secrets "$project" "$secret_id"
  elif [ "$action" = "save" ]; then
    save_secrets "$project" "$secret_id"
  else
    get_secret "$project" "$secret_id"
  fi
}



main "$@"
