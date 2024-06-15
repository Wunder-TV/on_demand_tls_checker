#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.

# Fix https://unix.stackexchange.com/a/38580
# We cannot do this in the Dockerfile, because the permission is not set on docker image build time but instead on docker container startup time
chmod og+w /proc/self/fd/2

# Check if SKIP_PRESTART is set and its value is true
if [[ -n "$OCY_CONTAINER_SLEEP" && "${OCY_CONTAINER_SLEEP,,}" == "true" ]]; then
    sleep 86400
else
    if [[ -n "$SKIP_PRESTART" && "${SKIP_PRESTART,,}" == "true" ]]; then
        # If SKIP_PRESTART is set to true, skip the pre-start tasks and execute the main process
        echo "Skipping Prestart... executing..."
        gosu www-data "$@"
    else
        # Pre-start tasks
        # Modify php.ini settings if the corresponding environment variables are set
        echo "Prestart running... "
        PHP_FPM_POOL_CONF=/usr/local/etc/php-fpm.d/docker.conf
        HOOK_FOLDER=/etc/docker-entrypoint.d/

        if [ -d "$HOOK_FOLDER/pre-hook" ]; then
            for f in ${HOOK_FOLDER}/pre-hook/*; do
                . "$f"
            done
        fi

        if [ -d "$HOOK_FOLDER/post-hook" ]; then
            for f in ${HOOK_FOLDER}/post-hook/*; do
                . "$f"
            done
        fi

    echo "executing command now..."
    # Execute the main process along with any arguments passed to the script
    gosu www-data "$@"
    fi
fi