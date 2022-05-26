#!/bin/sh

set -euo pipefail

source ./auth.sh

LI_GAMES=$(curl https://lichess.org/api/user/$LICHESS_USERNAME | jq '.perfs.rapid.games')
echo "Current Lichess rapid games: ${LI_GAMES}"

TMP_FILE=$(mktemp)
curl -s "${BEE}/users/${BEEMINDER_USERNAME}/goals/${RAPID_GOAL}/datapoints.json?${BEE_AUTH}&count=1" > $TMP_FILE
BEEM_GAMES=$(jq first.value $TMP_FILE)
echo "Current Beeminder # of rapid games: ${BEEM_GAMES}"

if [ $LI_GAMES -eq $BEEM_GAMES ]; then
    echo "Beeminder up to date; exiting"
    exit 0
fi

echo "Posting the new data..."
curl \
  --data "${BEE_AUTH}&value=${LI_GAMES}&comment=$(TZ=America/New_York date +"%H:%M:%S")" \
  "${BEE}/users/${BEEMINDER_USERNAME}/goals/${RAPID_GOAL}/datapoints.json"
