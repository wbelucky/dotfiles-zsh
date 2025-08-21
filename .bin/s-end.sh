#!/bin/bash

note="$1" yq -i '
.sessions[-1].end = (now | format_datetime("2006-01-02T15:04:05"))
' $ZK_NOTEBOOK_DIR/sessions/$(date +%y-%m).yaml
