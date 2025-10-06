#!/bin/bash

session_file="$ZK_NOTEBOOK_DIR/sessions/$(date +%y-%m).yaml"
note="$1" content="${2}" yq -i '
.sessions += [{"start": (now | format_datetime("2006-01-02T00:00:00")), "end": (now | format_datetime("2006-01-02T00:00:00")), "note": strenv(note), "content": strenv(content), "id": .last_id + 1}]
, .last_id = .last_id + 1' $session_file

