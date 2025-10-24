#!/bin/bash
session_file="$ZK_NOTEBOOK_DIR/sessions/$(date +%y-%m).yaml"
yq '.sessions | group_by(.note).[] | [{"note":.[0].note, "contents": ([.[].content] | join("\n"))}]' $session_file

# '[.sessions[] | with_dtf("2006-01-02T15:04:05"; (.end | to_unix) - (.start | to_unix))] | .[] as $item ireduce(0; . + $item)'
# TODO: shuho
# '.sessions | group_by(.note).[] | [{"duration": ([.[] | with_dtf("2006-01-02T15:04:05"; (.end | to_unix) - (.start | to_unix))] | .[] as $item ireduce(0; . + $item)),"note":.[0].note, "contents": ([.[].content] | join("\n"))}]'
