#!/usr/bin/env bash

# eval env vars
GCP_CLUSTER_NAME=$(eval "echo $ORB_EVAL_CLUSTER_NAME")
GCP_ARGS=$(eval "echo $ORB_EVAL_ADDITIONAL_ARGS")

args=()

if [ -n "$ORB_VAL_ZONE" ]; then
  args+=(--zone "$ORB_VAL_ZONE")
fi

export CLOUDSDK_CORE_DISABLE_PROMPTS=1
gcloud config set run/platform gke
gcloud config set project "$GOOGLE_PROJECT_ID"

set -x
gcloud beta container clusters delete "$GCP_CLUSTER_NAME" "${args[@]}" "$GCP_ARGS"
set +x
echo "Clusters deleted."
