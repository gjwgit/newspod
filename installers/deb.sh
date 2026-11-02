#!/bin/bash

# Build the Debian package for NewsPod.
#
# From the gjwgit/fluttertmpl Copier template, with the package details
# from .copier-answers.yml. Local edits are kept by `copier update`.
#
# 20261030 gjw One script for the local `make deb` and the installers
# workflow. Locally it builds the Flutter Linux release first. With
# --bundle it packages the bundle already in build/linux/x64/release, as
# the workflow's build-linux job leaves it, so every Linux installer
# carries the same binary.
#
# Run from the installers folder. Leaves newspod_<version>_amd64.deb
# here.

set -e

APP=newspod

VER=$(grep '^version:' ../pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)

if [ "$1" != "--bundle" ]; then
  (cd ..; flutter build linux --release)
fi

ROOT=${APP}_${VER}_amd64

# Create debian package structure.

mkdir -p ${ROOT}/DEBIAN
mkdir -p ${ROOT}/usr/bin
mkdir -p ${ROOT}/usr/lib/${APP}
mkdir -p ${ROOT}/usr/share/applications
mkdir -p ${ROOT}/usr/share/icons/hicolor/512x512/apps

# Create control file. The heredocs are quoted so the description is
# written as it is.

cat > ${ROOT}/DEBIAN/control << 'EOL'
Package: newspod
Section: news
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libblkid1, liblzma5
Maintainer: Graham Williams <graham.williams@togaware.com>
Description: A privacy-first news feed reader
 NewsPod gathers the news from the RSS and Atom feeds you choose into
 one list, newest first, with each story's source, time and summary.
 Tap a story to read it in full on its own site. Start with a few
 well known feeds, then add your own and remove any you do not want.
 .
 The app needs no login and has no account, no tracking and no
 algorithm deciding what you see. Your feeds are kept on your device.
 A login to your Solid Pod is optional, ready for features that keep
 your feeds and reading privately and encrypted on your own Pod.
EOL
echo "Version: ${VER}" >> ${ROOT}/DEBIAN/control

# Create desktop entry.

cat > ${ROOT}/usr/share/applications/com.togaware.${APP}.desktop << 'EOL'
[Desktop Entry]
Name=NewsPod
Comment=Simple, Private, Secure News Feed Reader
Exec=/usr/bin/newspod
Icon=newspod
Terminal=false
Type=Application
Categories=Network;News;
Keywords=news;rss;atom;feed;reader;solid;pod;
EOL

# Copy the built flutter application.

cp -r ../build/linux/x64/release/bundle/* ${ROOT}/usr/lib/${APP}/

# Ensure /usr/bin/${APP} points to the actual executable.

(cd ${ROOT}/usr/bin; ln -s ../lib/${APP}/${APP} ${APP})

# The app icon.

cp ../assets/images/app_icon.png ${ROOT}/usr/share/icons/hicolor/512x512/apps/${APP}.png

# Set correct permissions.

chmod 755 ${ROOT}
chmod -R 755 ${ROOT}/DEBIAN
find ${ROOT}/usr -type d -exec chmod 755 {} \;
find ${ROOT}/usr -type f -exec chmod 644 {} \;
chmod 755 ${ROOT}/usr/lib/${APP}/${APP}

# Build the debian package.

dpkg-deb --build --root-owner-group ${ROOT}

# Cleanup.

rm -rf ${ROOT}
