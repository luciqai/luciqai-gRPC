#!/bin/sh
set -eu
XCODE_XCCONFIG_FILE="$(cd "$(dirname "$0")/.." && pwd)/pod-lint.xcconfig"
export XCODE_XCCONFIG_FILE
exec pod "$@"
