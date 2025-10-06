#!/bin/bash
session_file="$ZK_NOTEBOOK_DIR/sessions/$(date +%y-%m).yaml"
if [[ $(yq '.sessions[-1] | has("end") | not' $session_file) = 'true' ]]; then
	SCRIPT_DIR=$(cd $(dirname $0) && pwd)
	source "$SCRIPT_DIR/s-end.sh"
fi
note="$1" content="${2}" yq -i '
.sessions += [{"start": (now | format_datetime("2006-01-02T15:04:05")), "note": strenv(note), "content": strenv(content), "id": .last_id + 1}]
, .last_id = .last_id + 1' $session_file
