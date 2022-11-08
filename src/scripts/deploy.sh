#!/usr/bin/env bash

GCP_ARGS=$(eval "echo $ORB_EVAL_ADDITIONAL_ARGS")

case $ORB_VAL_PLATFORM in
    managed)
    echo 'Platform: Managed'
    # Check for required parameters

    if [ -z "$ORB_VAL_REGION" ]; then
        echo 'The region parameter is required for the "managed" platform.'
        exit 1
    fi

    if [ -z "$ORB_VAL_SERVICE_NAME" ]; then
        echo 'The service-name parameter is required for the "managed" platform.'
        exit 1
    fi

    managed_args=()

    if [ -n "$ORB_VAL_IMAGE" ]; then
        managed_args+=(--image "$ORB_VAL_IMAGE")
    fi

    if [ "$ORB_VAL_UNAUTHENTICATED" = 1 ]; then
        managed_args+=(--allow-unauthenticated)
    else
        managed_args+=(--no-allow-unauthenticated)
    fi

    # End of parameter check
    # Deployment command
    gcloud run deploy "$ORB_VAL_SERVICE_NAME" "${managed_args[@]}" --platform managed --region "$ORB_VAL_REGION" "${GCP_ARGS}"
    echo
    echo "Service deployed"
    echo
    GET_GCP_DEPLOY_ENDPOINT=$(gcloud run services describe "$ORB_VAL_SERVICE_NAME" --platform managed --region "$ORB_VAL_REGION" --format="value(status.address.url)")
    echo "export GCP_DEPLOY_ENDPOINT=$GET_GCP_DEPLOY_ENDPOINT" >> "$BASH_ENV"
    # shellcheck source=/dev/null
    source "$BASH_ENV"
    echo "$GCP_DEPLOY_ENDPOINT"
    ;;
    gke)
    echo 'Platform: GKE'
    # Check for required parameters
    if [ -z "$ORB_VAL_CLUSTER" ]; then
        echo 'The cluster parameter is required for the "gke" platform.'
        exit 1
    fi

    if [ -z "$ORB_VAL_CLUSTER_LOCATION" ]; then
        echo 'The cluster-location parameter is required for the "gke" platform.'
        exit 1
    fi

    gke_args=()

    if [ -n "$ORB_VAL_IMAGE" ]; then
        gke_args+=(--image "$ORB_VAL_IMAGE")
    fi

    if [ -n "$ORB_VAL_CLUSTER" ]; then
        gke_args+=(--cluster "$ORB_VAL_CLUSTER")
    fi

    if [ -n "$ORB_VAL_CLUSTER_LOCATION" ]; then
        gke_args+=(--cluster-location "$ORB_VAL_CLUSTER_LOCATION")
    fi

    # End of parameter check
    # Deployment command
    echo "Ensure all required APIs are enabled"
    echo
    gcloud services enable container.googleapis.com containerregistry.googleapis.com cloudbuild.googleapis.com
    echo
    gcloud run deploy "$ORB_VAL_SERVICE_NAME" "${gke_args[@]}" --platform gke "${GCP_ARGS}"
    echo
    echo "Service deployed"
    echo
    ;;
esac