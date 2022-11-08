#!/usr/bin/env bash

# eval env vars
GCP_SOURCE=$(eval "echo $ORB_EVAL_SOURCE")
GCP_TAG=$(eval "echo $ORB_EVAL_TAG")
GCP_CONFIG=$(eval "echo $ORB_EVAL_CONFIG")
GCP_ARGS=$(eval "echo $ORB_EVAL_ARGS")

# if no source parameter is set, check for a Dockerfile and fail if none is found.
if [ ! -f Dockerfile ] && [ -z "$GCP_SOURCE" ]; then
    echo "No Dockerfile in $(pwd). You may need to specify a source location."
    exit 1
fi

# Populate args array with additional args
IFS=" " read -a args -r <<< "${GCP_ARGS[@]}"

if [ -n "$GCP_TAG" ]; then
  args+=(--tag "$GCP_TAG")
fi

if [ -n "$GCP_CONFIG" ]; then
  args+=(--config "$GCP_CONFIG")
fi

args+=("$GCP_ARGS")

set -x
gcloud builds submit --source "$GCP_SOURCE" "${args[@]}"
set +x
