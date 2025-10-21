#!/bin/sh

# startup.sh

# --- Configuration ---
# Use environment variables with sensible defaults
# The label selector to find the web app pods (e.g., "app=my-webapp")
LABEL_SELECTOR="app=b42"

# The namespace to search for pods in
NAMESPACE=${NAMESPACE:-"b42"}

# The container inside the pod
CONTAINER=${CONTAINER:-"b42"}

# The GoAccess config file
CONFIG_FILE=${CONFIG_FILE:-"/etc/goaccess/goaccess.conf"}

# The GoAccess log format (e.g., COMBINED)
LOG_FORMAT=${LOG_FORMAT:-"COMBINED"}

# The path to the real-time HTML report GoAccess will generate
#REPORT_PATH="/usr/share/nginx/html/report.html"
REPORT_PATH=${REPORT_PATH:-"/reports/index.html"}

# The startup mode: real-time or one-shot
STARTUP_MODE=${STARTUP_MODE:="real-time"}

# --- Validation ---
echo "--- GoAccess Live Log Analyzer ---"
echo "Namespace:        ${NAMESPACE}"
echo "Label Selector:   ${LABEL_SELECTOR}"
echo "Log Format:       ${LOG_FORMAT}"
echo "Report Path:      ${REPORT_PATH}"
echo "----------------------------------"

# Ensure the output directory exists
mkdir -p $(dirname ${REPORT_PATH})

# --- Execution ---
# Start the kubectl log stream and pipe it to GoAccess
# The final hyphen '-' tells GoAccess to read from standard input

if [ ${STARTUP_MODE} == "real-time" ]; then
  kubectl logs -n ${NAMESPACE} -f --ignore-errors -l ${LABEL_SELECTOR} -c ${CONTAINER} |
    grep --line-buffered -v ^2025 |
    goaccess -p ${CONFIG_FILE} --real-time-html -o ${REPORT_PATH} --restore --persist -
else
  kubectl logs -n ${NAMESPACE} -l ${LABEL_SELECTOR} -c ${CONTAINER} |
    grep --line-buffered -v ^2025 |
    goaccess -p ${CONFIG_FILE} -o ${REPORT_PATH} --restore --persist -
fi
