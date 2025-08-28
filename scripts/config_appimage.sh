#!/bin/bash

APPDIR="$HOME/appimage"
DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$DESKTOP_DIR"

for APP in "$APPDIR"/*.AppImage; do
    [ -e "$APP" ] || continue  # Skip if no AppImages

    APPNAME=$(basename "$APP" .AppImage)
    DESKTOP_FILE="$DESKTOP_DIR/$APPNAME.desktop"

    # Skip if desktop entry already exists
    if [ -f "$DESKTOP_FILE" ]; then
        echo "Skipping existing: $APPNAME"
        continue
    fi

    # Optional: Try to extract icon from AppImage
    ICON="$APPDIR/$APPNAME.png"
    if [ ! -f "$ICON" ]; then
        # If no PNG exists, fallback to generic icon
        ICON="/usr/share/pixmaps/application-x-executable.png"
    fi

    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$APPNAME
Comment=AppImage $APPNAME
Exec=$APP
Icon=$ICON
Terminal=false
Type=Application
Categories=Utility;
EOF

    chmod +x "$DESKTOP_FILE"
    echo "Registered: $APPNAME"
done

echo "Done registering AppImages."

