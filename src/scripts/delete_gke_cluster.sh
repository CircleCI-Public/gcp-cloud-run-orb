#!/usr/bin/env bash

# eval env vars
GCP_CLUSTER_NAME=$(eval "echo $ORB_EVAL_CLUSTER_NAME")
GCP_ZONE=$(eval "echo $ORB_EVAL_ZONE")
GCP_ARGS=$(eval "echo $ORB_EVAL_ADDITIONAL_ARGS")

# Initialize args array with additional args
IFS=" " read -a args -r <<< "${GCP_ARGS[@]}"

if [ -n "$GCP_ZONE" ]; then
  args+=(--zone "$GCP_ZONE")
fi

args+=("$GCP_ARGS")

export CLOUDSDK_CORE_DISABLE_PROMPTS=1
gcloud config set run/platform gke
gcloud config set project "$GOOGLE_PROJECT_ID"

set -x
gcloud container clusters delete "$GCP_CLUSTER_NAME" "${args[@]}"
set +x
echo "Clusters deleted."
