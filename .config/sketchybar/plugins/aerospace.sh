#!/usr/bin/env bash


case $FOCUSED_WORKSPACE in
  0) label="Terminal" ;;
  1) label="Web" ;;
  2) label="App" ;;
  3) label="Slack" ;;
  9) label="Whatsapp" ;;
  10) label="Lemon" ;;
  *) label="Desktop $FOCUSED_WORKSPACE" ;;
esac

sketchybar --set aerospace label="$label"
