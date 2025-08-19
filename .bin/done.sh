#!/bin/bash
yq -i --front-matter=process '.tags |= (del(.[] | select(. == "status:*"))) | .tags += ["status:done"] | .closed_at = (now | format_datetime("2006-01-02 15:04:05"))' $1
