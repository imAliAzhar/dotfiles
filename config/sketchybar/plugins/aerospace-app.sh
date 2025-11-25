#!/usr/bin/env bash

app=$(aerospace list-windows --focused --json | jq -r '.[0].["app-name"]')

label=""

if [[ "$app" != "" ]]; then
  label="/   $app"
fi

$BAR_NAME --set app label="$label"
