#!/bin/bash

if [[ ! -d "/data/$PSYSH_MANUAL_LANGUAGE" ]]; then
    echo "\"$PSYSH_MANUAL_LANGUAGE\" language is not yet supported. Setting \"en\" as language."
    export PSYSH_MANUAL_LANGUAGE=en
fi

exec /vendor/bin/psysh --config=/config.php "$@"
