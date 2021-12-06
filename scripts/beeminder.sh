#!/bin/sh
set -euo pipefail

GAMES=$(curl https://lichess.org/api/user/$LICHESS_USERNAME | jq '.perfs.blitz.games + .perfs.rapid.games')
curl \
  --data "auth_token=${BEEMINDER_API_TOKEN}&value=${GAMES}&comment=${GAMES} played as of $(date +"%H:%M:%S")" \
  "https://www.beeminder.com/api/v1/users/${BEEMINDER_USERNAME}/goals/${GOAL}/datapoints.json"
