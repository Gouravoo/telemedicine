#!/bin/bash
if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable
else
  echo "Flutter SDK already exists."
fi
export PATH="$PATH:`pwd`/flutter/bin"
flutter/bin/flutter config --enable-web
flutter/bin/flutter pub get
