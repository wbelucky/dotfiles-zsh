#!/bin/bash
note="$1" content="${2:-''}" yq -i '
.sessions += [{"start": (now | format_datetime("2006-01-02T15:04:05")), "note": strenv(note), "content": strenv(content)}]
' $ZK_NOTEBOOK_DIR/sessions/$(date +%y-%m).yaml
