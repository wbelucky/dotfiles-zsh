#!/bin/zsh

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
	-X POST \
	--json "$(jq --arg text "$([ -z "$1"] && cat - || echo "$1")" -n '.contents[0].parts[0].text = $text')" | jq -r ".candidates[0].content.parts[0].text"
