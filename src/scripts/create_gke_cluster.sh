#!/usr/bin/env bash

# eval env vars
GCP_CLUSTER_NAME=$(eval "echo $ORB_EVAL_CLUSTER_NAME")
GCP_ARGS=$(eval "echo $ORB_EVAL_ADDITIONAL_ARGS")

args=()

if [ -n "$ORB_VAL_ADDONS" ]; then
  args+=(--addons "$ORB_VAL_ADDONS")
fi

if [ -n "$ORB_VAL_MACHINE_TYPE" ]; then
  args+=(--machine-type "$ORB_VAL_MACHINE_TYPE")
fi

if [ -n "$ORB_VAL_ZONE" ]; then
  args+=(--zone "$ORB_VAL_ZONE")
fi

if [ -n "$ORB_VAL_SCOPES" ]; then
  args+=(--scopes "$ORB_VAL_SCOPES")
fi

if [ "$ORB_VAL_ENABLE_STACKDRIVER" = 1 ]; then
  args+=(--enable-stackdriver-kubernetes)
fi

gcloud config set run/platform gke
gcloud config set project "$GOOGLE_PROJECT_ID"

set -x
gcloud container clusters create "$GCP_CLUSTER_NAME" "${args[@]}" "$GCP_ARGS"
set +x
