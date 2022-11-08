#!/usr/bin/env bash

# eval env vars
GCP_CLUSTER_NAME=$(eval "echo $ORB_EVAL_CLUSTER_NAME")
GCP_ARGS=$(eval "echo $ORB_EVAL_ADDITIONAL_ARGS")
GCP_ZONE=$(eval "echo $ORB_EVAL_ZONE")
GCP_MACHINE_TYPE=$(eval "echo $ORB_EVAL_MACHINE_TYPE")

args=()

if [ -n "$ORB_VAL_ADDONS" ]; then
  args+=(--addons "$ORB_VAL_ADDONS")
fi

if [ -n "$GCP_MACHINE_TYPE" ]; then
  args+=(--machine-type "$GCP_MACHINE_TYPE")
fi

if [ -n "$GCP_ZONE" ]; then
  args+=(--zone "$GCP_ZONE")
fi

if [ -n "$ORB_VAL_SCOPES" ]; then
  args+=(--scopes "$ORB_VAL_SCOPES")
fi

if [ "$ORB_VAL_ENABLE_STACKDRIVER" = 1 ]; then
  args+=(--enable-stackdriver-kubernetes)
fi

args+=("$GCP_ARGS")

gcloud config set run/platform gke
gcloud config set project "$GOOGLE_PROJECT_ID"

set -x
gcloud container clusters create "$GCP_CLUSTER_NAME" "${args[@]}"
set +x
