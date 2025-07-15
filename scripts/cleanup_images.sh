#!/bin/bash

if [ -z "${1}" ]; then
  echo "Usage: $0 <GCP_PROJECT_ID>"
  exit 1
fi

PROJECT="$1"
FAMILY="webapp-family"

LATEST_IMAGE=$(gcloud compute images describe-from-family "$FAMILY" --project="$PROJECT" --format='value(name)')
IMAGES_TO_DELETE=$(gcloud compute images list --project="$PROJECT" --filter="family=$FAMILY AND name!=$LATEST_IMAGE" --format="value(name)")

for IMAGE in $IMAGES_TO_DELETE; do
  echo "Deleting $IMAGE"
  gcloud compute images delete "$IMAGE" --project="$PROJECT" --quiet
done

