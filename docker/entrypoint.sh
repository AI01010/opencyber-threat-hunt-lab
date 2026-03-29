#!/usr/bin/env bash
set -e

g='\033[0;32m'
y='\033[0;33m'
n='\033[0m'

echo
echo -e "   __   __   __   ___ "
echo -e "  /  \` /  \ |  \ |__  "
echo -e "  \__, \__/ |__/ |___ "
echo -e "   __       ___       "
echo -e "  |__)  /\   |   |__|  "
echo -e "  |    /--\  |   |  |  "
echo -e "        __   __   ___  "
echo -e "  ${g}\|/  ${n}/  \ |__) / _   "
echo -e "  ${g}/|\  ${n}\__/ |  \ \__/  "
echo
echo -e "Welcome to the ${g}Threat Hunt Lab${n} environment!"
echo

echo "Keep this terminal open while you work — closing it stops Splunk."
echo "Splunk takes 60–90 seconds to start."
echo
read -rp "Ready to get started? [y/N] " answer
case "$answer" in
    [yY]|[yY][eE][sS]) ;;
    *)
        echo
        echo "No problem — run the same command again when you're ready."
        exit 0
        ;;
esac
echo

# Start Splunk (suppress verbose startup output)
echo "Starting Splunk..."
/opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt > /dev/null 2>&1

# Wait for Splunk to be ready.
# Free license is pre-configured in the image via server.conf, so no runtime
# license activation or restart is needed on any run.
echo -n "Waiting for Splunk to initialize"
until /opt/splunk/bin/splunk status 2>/dev/null | grep -q 'is running'; do
    printf '.'
    sleep 3
done
echo

echo
echo -e "${g}============================================${n}"
echo -e "${g}  Splunk is ready!${n}"
echo
echo -e "  Open your browser and go to:"
echo -e "    ${g}http://localhost:8000${n}"
echo
echo -e "  Log in with:"
echo -e "    Username: ${g}admin${n}"
echo -e "    Password: ${g}codepath${n}"
echo -e "${g}============================================${n}"
echo
echo "Press Ctrl+C to stop Splunk and exit."
echo

# Keep container alive
sleep infinity
