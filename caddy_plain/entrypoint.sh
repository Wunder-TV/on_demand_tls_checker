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
        echo "Prestart running... "
        HOOK_FOLDER=/etc/docker-entrypoint.d/

        if [ -d "$HOOK_FOLDER/pre-hook" ]; then
            for f in ${HOOK_FOLDER}/pre-hook/*; do
                . "$f"
            done
        fi

        if [ "${OCY_CADDYFILE_OVERWRITE:-}" ]; then
            if [ -s ${OCY_CADDYFILE_OVERWRITE} ]; then
                echo "copy ${OCY_CADDYFILE_OVERWRITE} to /etc/caddy/Caddyfile"
                cp ${OCY_CADDYFILE_OVERWRITE} /etc/caddy/Caddyfile
            else
                echo "OCY_CADDYFILE_OVERWRITE-File ${OCY_CADDYFILE_OVERWRITE} does not exist or is empty!"
                exit 0
            fi
        else
            if [ "${OCY_APP_FRAMEWORK:-}" ]; then 
                if [[ ${OCY_BASICAUTH_ENABLED} ]]; then
                    echo "write specifc ${OCY_APP_FRAMEWORK} Caddyfile with ${OCY_BASICAUTH_USER:-onacy} User for basic-auth."
                    CADDY_PASSWD=$(caddy hash-password -p${OCY_BASICAUTH_PASSWD:-onacy})
                    awk -v user="${OCY_BASICAUTH_USER:-onacy}" -v passwd="${CADDY_PASSWD}" '
                        BEGIN {printing=1}
                        /basicauth \/\* {/ {print; printing=0}
                        /}/ {
                            if (!printing) {
                                print "            " user " " passwd
                                print
                            }
                            printing=1
                        }
                        printing' /etc/caddy/alt_Caddyfiles/${OCY_APP_FRAMEWORK}_basicauth > /etc/caddy/Caddyfile
                else
                    echo "wrote specifc ${OCY_APP_FRAMEWORK} Caddyfile"
                    cp /etc/caddy/alt_Caddyfiles/${OCY_APP_FRAMEWORK} /etc/caddy/Caddyfile            
                fi
            else
                echo "Set OCY_APP_FRAMEWORK variable (e.g. shopware, laravel)"
                exit 0 
            fi
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