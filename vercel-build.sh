#!/usr/bin/env bash
# Vercel's build image has no Flutter SDK, so this installs a pinned stable
# release (shallow clone, cached across builds by Vercel's build cache since
# it lives outside the repo at $FLUTTER_HOME) and then builds the web app.
set -euo pipefail

FLUTTER_HOME="$(pwd)/.flutter-sdk"
FLUTTER_VERSION="3.44.0"

if [ ! -d "$FLUTTER_HOME" ]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"

flutter config --enable-web --no-analytics
flutter pub get
flutter build web --release
