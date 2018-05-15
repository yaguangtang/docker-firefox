#
# firefox Dockerfile
#
# https://github.com/jlesage/docker-firefox
#

# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-16.04

# Define software versions.
#ARG PROFILE_CLEANER_VERSION=2.36

# Define software download URLs.
ARG JSONLZ4_URL=http://github.com/avih/dejsonlz4/archive/c4305b8.tar.gz
ARG LZ4_URL=http://github.com/lz4/lz4/archive/v1.8.1.2.tar.gz
#ARG PROFILE_CLEANER_URL=https://github.com/graysky2/profile-cleaner/raw/v${PROFILE_CLEANER_VERSION}/common/profile-cleaner.in

# Define working directory.
WORKDIR /tmp

# Install Firefox.
RUN     add-pkg firefox \
        fonts-arphic-uming \
        fonts-arphic-ukai \
        desktop-file-utils \
        adwaita-icon-theme \
        ttf-dejavu \
        x264 \
        pulseaudio \
        # The following package is used to send key presses to the X process.
        xdotool

# Set default settings.
#RUN \
#    CFG_FILE="$(ls /usr/lib/firefox-*/browser/defaults/preferences/firefox-branding.js)" && \
#    echo '' >> "$CFG_FILE" && \
#    echo '// Default download directory.' >> "$CFG_FILE" && \
#    echo 'pref("browser.download.dir", "/config/downloads");' >> "$CFG_FILE" && \
#    echo 'pref("browser.download.folderList", 2);' >> "$CFG_FILE"


# Install profile-cleaner.
#RUN \
#    add-pkg --virtual build-dependencies curl && \
#    curl -# -L -o /usr/bin/profile-cleaner {$PROFILE_CLEANER_URL} && \
#    sed-patch 's/@VERSION@/'${PROFILE_CLEANER_VERSION}'/' /usr/bin/profile-cleaner && \
#    chmod +x /usr/bin/profile-cleaner && \
#    add-pkg \
#        bash \
#        file \
#        coreutils \
#        bc \
#        parallel \
#        sqlite \
#        && \
#    # Cleanup.
#    del-pkg build-dependencies && \
#    rm -rf /tmp/* /tmp/.[!.]*

# Enable log monitoring.
RUN \
    add-pkg yad && \
    sed-patch 's|LOG_FILES=|LOG_FILES=/config/log/firefox/error.log|' /etc/logmonitor/logmonitor.conf && \
    sed-patch 's|STATUS_FILES=|STATUS_FILES=/tmp/.firefox_shm_check|' /etc/logmonitor/logmonitor.conf

# Adjust the openbox config.
RUN \
    # Maximize only the main window.
    sed-patch 's/<application type="normal">/<application type="normal" title="Mozilla Firefox">/' \
        /etc/xdg/openbox/rc.xml && \
    # Make sure the main window is always in the background.
    sed-patch '/<application type="normal" title="Mozilla Firefox">/a \    <layer>below</layer>' \
        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/firefox-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="Firefox"
ENV LANG=en_US.UTF-8


# Define mountable directories.
VOLUME ["/config"]

# Metadata.
LABEL \
      org.label-schema.name="firefox" \
      org.label-schema.description="Docker container for Firefox" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-firefox" \
      org.label-schema.schema-version="1.0"
