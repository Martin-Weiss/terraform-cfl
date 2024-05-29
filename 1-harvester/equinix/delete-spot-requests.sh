#!/bin/bash
API_TOKEN=$(cat ../../.metal_auth_token)
IDS="4376edd5-0200-4fcd-8a16-030593c8f453 37f0f28d-9518-4bc0-bb0d-d9ef57ae4627 4b00ae42-2961-43e0-bf85-7357ef8913ab"
for ID in $IDS; do
	curl -X DELETE -H "X-Auth-Token: $API_TOKEN" \
https://api.equinix.com/metal/v1//spot-market-requests/$ID
done
