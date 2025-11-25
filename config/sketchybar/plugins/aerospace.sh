#!/usr/bin/env bash

case $FOCUSED_WORKSPACE in
0) label="Term" ;;
1) label="Arc" ;;
2) label="App" ;;
3) label="Slack" ;;
9) label="Whatsapp" ;;
10) label="Lemon" ;;
*) label="Desktop $FOCUSED_WORKSPACE" ;;
esac

$BAR_NAME --set aerospace label="$label"
