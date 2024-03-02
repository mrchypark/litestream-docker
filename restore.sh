#!/bin/sh

if [ "${DB_PATH}" = "" ]; then
  debug_echo "DB_PATH environment variable is not set or empty. Exiting script."
  exit 1
fi

if [ "${DB_NAME}" = "" ]; then
  debug_echo "DB_NAME environment variable is not set or empty. Exiting script."
  exit 1
fi

if [ "${REPLICA_PATH}" = "" ]; then
  debug_echo "REPLICA_PATH environment variable is not set or empty. Exiting script."
  exit 1
fi

GENERATIONS_OUTPUT=$(litestream generations "${DB_PATH}/${DB_NAME}")

if echo "$GENERATIONS_OUTPUT" | awk 'NR>1 && $3 ~ /^-/ {found=1; exit} END {if (found) print "true"}'; then
  debug_echo "Negative lag detected. Restore Start."
  rm -Rf "${TEMP_PATH}"
  mkdir -p "${TEMP_PATH}" 
  litestream restore -o "${TEMP_PATH}/${DB_NAME}" "${REPLICA_PATH}"
  cp -fRp "${TEMP_PATH}"/* "${DB_PATH}"
  sqlite3 "${DB_PATH}/${DB_NAME}" 'PRAGMA wal_checkpoint(TRUNCATE);'
  rm -Rf "${TEMP_PATH}"
  debug_echo "Restore done."
else
  debug_echo "All generations are up-to-date. No action is performed."
  sleep $CHECK_INTERVAL
fi