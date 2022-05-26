#!/bin/sh
set -euo pipefail

source ./auth.sh

./rapid.sh

echo "Lichess offset: ${LI_OFFSET}" 
LI_GAMES=$(curl https://lichess.org/api/user/$LICHESS_USERNAME | jq '.perfs.blitz.games + .perfs.rapid.games')
echo "Current Lichess games: ${LI_GAMES}"

TMP_FILE=$(mktemp)
curl -s "${BEE}/users/${BEEMINDER_USERNAME}/goals/${GOAL}/datapoints.json?${BEE_AUTH}&count=1" > $TMP_FILE
BEEM_GAMES=$(jq first.value $TMP_FILE)
echo "Current Beeminder # of games: ${BEEM_GAMES}"

echo "Chess.com offset: ${CHESSCOM_OFFSET}"
CHESSCOM_GAMES=$(curl https://api.chess.com/pub/player/$CHESSCOM_USER/stats | jq \
  '. | [.chess_blitz.record, .chess_rapid.record] | [.[].win, .[].loss, .[].draw] | add')

LI_TOTAL_GAMES=$(($LI_GAMES - $LI_OFFSET))
CHESSCOM_TOTAL_GAMES=$(($CHESSCOM_GAMES - $CHESSCOM_OFFSET))
TOTAL_GAMES=$(($CHESSCOM_TOTAL_GAMES + LI_TOTAL_GAMES))

if [ $TOTAL_GAMES -eq $BEEM_GAMES ]; then
    echo "Beeminder up to date; exiting"
    exit 0
fi

echo "Posting the new data..."
curl \
  --data "${BEE_AUTH}&value=${TOTAL_GAMES}&comment=Lichess: ${LI_GAMES}, Chesscom: ${CHESSCOM_GAMES} as of $(TZ=America/New_York date +"%H:%M:%S")" \
  "${BEE}/users/${BEEMINDER_USERNAME}/goals/${GOAL}/datapoints.json"
