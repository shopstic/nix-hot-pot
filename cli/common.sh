#!/usr/bin/env bash
set -euo pipefail

fn_fatal() {
  local exit_code=$?
  local message=${1:?"Message is required"}
  echo "$message" >&2
  exit "$exit_code"
}