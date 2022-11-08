#!/usr/bin/env bash

GCP_ARGS=$(eval "echo $ORB_EVAL_ADDITIONAL_ARGS")
GCP_IMAGE=$(eval "echo $ORB_EVAL_IMAGE")
GCP_SERVICE_NAME=$(eval "echo $ORB_EVAL_SERVICE_NAME")
GCP_REGION=$(eval "echo $ORB_EVAL_REGION")
GCP_CLUSTER=$(eval "echo $ORB_EVAL_CLUSTER")
GCP_CLUSTER_LOCATION=$(eval "echo $ORB_EVAL_CLUSTER_LOCATION")

case $ORB_VAL_PLATFORM in
    managed)
    echo 'Platform: Managed'
    # Check for required parameters

    if [ -z "$GCP_REGION" ]; then
        echo 'The region parameter is required for the "managed" platform.'
        exit 1
    fi

    if [ -z "$GCP_SERVICE_NAME" ]; then
        echo 'The service-name parameter is required for the "managed" platform.'
        exit 1
    fi

    managed_args=()

    if [ -n "$GCP_IMAGE" ]; then
        managed_args+=(--image "$GCP_IMAGE")
    fi

    if [ "$ORB_VAL_UNAUTHENTICATED" = 1 ]; then
        managed_args+=(--allow-unauthenticated)
    else
        managed_args+=(--no-allow-unauthenticated)
    fi

    managed_args+=("$GCP_ARGS")

    # End of parameter check
    # Deployment command
    gcloud run deploy "$GCP_SERVICE_NAME" --platform managed --region "$GCP_REGION" "${managed_args[@]}"
    echo
    echo "Service deployed"
    echo
    GET_GCP_DEPLOY_ENDPOINT=$(gcloud run services describe "$GCP_SERVICE_NAME" --platform managed --region "$GCP_REGION" --format="value(status.address.url)")
    echo "export GCP_DEPLOY_ENDPOINT=$GET_GCP_DEPLOY_ENDPOINT" >> "$BASH_ENV"
    # shellcheck source=/dev/null
    source "$BASH_ENV"
    echo "$GCP_DEPLOY_ENDPOINT"
    ;;
    gke)
    echo 'Platform: GKE'
    # Check for required parameters
    if [ -z "$GCP_CLUSTER" ]; then
        echo 'The cluster parameter is required for the "gke" platform.'
        exit 1
    fi

    if [ -z "$GCP_CLUSTER_LOCATION" ]; then
        echo 'The cluster-location parameter is required for the "gke" platform.'
        exit 1
    fi

    gke_args=()

    if [ -n "$GCP_IMAGE" ]; then
        gke_args+=(--image "$GCP_IMAGE")
    fi

    if [ -n "$GCP_CLUSTER" ]; then
        gke_args+=(--cluster "$GCP_CLUSTER")
    fi

    if [ -n "$GCP_CLUSTER_LOCATION" ]; then
        gke_args+=(--cluster-location "$GCP_CLUSTER_LOCATION")
    fi

    gke_args+=("$GCP_ARGS")
    
    # End of parameter check
    # Deployment command
    echo "Ensure all required APIs are enabled"
    echo
    gcloud services enable container.googleapis.com containerregistry.googleapis.com cloudbuild.googleapis.com
    echo
    gcloud run deploy "$GCP_SERVICE_NAME"  --platform gke "${gke_args[@]}"
    echo
    echo "Service deployed"
    echo
    ;;
esac