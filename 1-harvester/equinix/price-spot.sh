#!/bin/bash
API_TOKEN=$(cat ../../.metal_auth_token)
curl -X GET -H "X-Auth-Token: $API_TOKEN " \
https://api.equinix.com/metal/v1/market/spot/prices >price-spot.json
jq . price-spot.json
