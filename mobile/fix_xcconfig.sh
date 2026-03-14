#!/bin/sh
# Run this after every `flutter pub get` to fix comma-in-path iOS build errors.
# Root cause: Flutter's assemble tool splits -d flag values on commas, breaking
# paths that contain commas (like this project's directory name).
REAL="Muazzin - Qibla, Salah, Quran"
LINK="MuazzinApp"
BASE="/Users/07kamrul/Developer"

# Ensure symlink exists
if [ ! -L "$BASE/$LINK" ]; then
  ln -snf "$BASE/$REAL" "$BASE/$LINK"
  echo "Symlink created: $BASE/$LINK"
fi

# Patch Generated.xcconfig
sed -i '' "s|$BASE/$REAL/mobile|$BASE/$LINK/mobile|g" \
  "$BASE/$REAL/mobile/ios/Flutter/Generated.xcconfig"

# Patch flutter_export_environment.sh
sed -i '' "s|$BASE/$REAL/mobile|$BASE/$LINK/mobile|g" \
  "$BASE/$REAL/mobile/ios/Flutter/flutter_export_environment.sh"

echo "xcconfig paths patched — iOS build should work now."
