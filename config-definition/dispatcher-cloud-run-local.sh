#!/usr/bin/env bash

set -o errexit
# errtrace is required to handle ERR trap correctly
#
# Further reading: https://stackoverflow.com/a/35800451/6802186
set -o errtrace
set -o pipefail
set -o nounset

# -----------------------------------------------------------------------------
# Global variables
# -----------------------------------------------------------------------------
declare AEM_SDK_DISPATCHER_TOOLS="${AEM_SDK_DISPATCHER_TOOLS}"
declare DISP_PORT="${DISP_PORT:-45031}"
declare PUBLISH_PORT="${PUBLISH_PORT:-4503}"
declare DISP_PRESERVE_CACHE="${DISP_PRESERVE_CACHE:-0}"

# -----------------------------------------------------------------------------
# Variables passed to dispatcher container
# -----------------------------------------------------------------------------
declare -x DISP_RUN_MODE="${DISP_RUN_MODE:-dev}"
declare -x REWRITE_LOG_LEVEL="${REWRITE_LOG_LEVEL:-trace1}"
declare -x DISP_LOG_LEVEL="${DISP_LOG_LEVEL:-trace1}"

# -----------------------------------------------------------------------------
# Local variables
# -----------------------------------------------------------------------------
declare -r validator_output_dir="target/validator-output"
declare -r config_dir="src"
declare -r docker_host_domain="host.docker.internal"

# -----------------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------------
declare -r RED_COLOR='\033[0;31m'
declare -r YELLOW_COLOR='\033[0;33m'
declare -r BLUE_COLOR='\033[0;34m'
declare -r NO_COLOR='\033[0m'

# -----------------------------------------------------------------------------
# Utils
# -----------------------------------------------------------------------------
function info_log {
    echo -e "[${BLUE_COLOR}INFO${NO_COLOR}] [$(date -R)] $1"
}

function warn_log {
    echo -e "[${YELLOW_COLOR}WARN${NO_COLOR}] [$(date -R)] $1"
}

function error_log {
    echo -e "[${RED_COLOR}ERROR${NO_COLOR}] [$(date -R)] $1"
}

function in_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

function git_root() {
    if in_git_repo; then
        git rev-parse --show-toplevel
    else
        error_log "Not in Git repository!"
        exit 1
    fi
}
# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
function prerequisites {
    info_log "Checking dispatcher prerequisites..."

    if [[ -z ${AEM_SDK_DISPATCHER_TOOLS} ]]; then
        error_log "AEM_SDK_DISPATCHER_TOOLS variable is not set!"
        exit 1
    elif [[ ! -d ${AEM_SDK_DISPATCHER_TOOLS} ]]; then
        error_log "$AEM_SDK_DISPATCHER_TOOLS is not a directory!"
        exit 1
    elif [[ ! -x "${AEM_SDK_DISPATCHER_TOOLS}/bin/docker_run.sh" || ! -L "${AEM_SDK_DISPATCHER_TOOLS}/bin/validator" ]]; then
        error_log "$AEM_SDK_DISPATCHER_TOOLS directory doesn't contain required files!"
        exit 1
    fi

    # docker_run.sh mounts "/mnt/var/www" from the container to "cache" folder
    # in your current directory. That's fine as long as you run the script from
    # "dispatcher" directory. Otherwise, you may end up with multiple "cache"
    # directories scattered around your workspace. In order to prevent that,
    # let's make sure the script was executed from the right place
    if [[ $(basename "${PWD}") != "dispatcher" || ! -d "${PWD}/src" || ! -d "${PWD}/src/conf.d" || ! -d "${PWD}/src/conf.dispatcher.d" ]]; then
        dispatcher_dir="$(git_root)/dispatcher"
        warn_log "The script was not executed from dispatcher directory. Changing it to ${dispatcher_dir}"
        cd "${dispatcher_dir}"
    fi

    info_log "AEM_SDK_DISPATCHER_TOOLS: ${AEM_SDK_DISPATCHER_TOOLS}"
    info_log "DISP_PORT: ${DISP_PORT}"
    info_log "PUBLISH_PORT: ${PUBLISH_PORT}"
    info_log "DISP_PRESERVE_CACHE: ${DISP_PRESERVE_CACHE}"
    info_log "DISP_RUN_MODE: ${DISP_RUN_MODE}"
    info_log "REWRITE_LOG_LEVEL: ${REWRITE_LOG_LEVEL}"
    info_log "DISP_LOG_LEVEL: ${DISP_LOG_LEVEL}"
    info_log "Done"
}

function conf_build {
    mvn -Pfast -Dconga.environments=cloud -Dconga.nodes=aem-dispatcher -Dconga.cloudManager.dispatcherConfig.skip=false clean package

    if [[ $? != 0 ]]; then
        error_log "Dispatcher config build failed (see messages above)!"
        exit 1
    fi
}

function conf_validation {
    if [[ -d "${validator_output_dir}" ]]; then
        info_log "Removing ${validator_output_dir}..."
        rm -rf "${validator_output_dir}" && info_log "Done"
    else
        # Make sure expected directory structure exists, as it could have been
        # deleted by "mvn clean"
        warn_log "${validator_output_dir} does not exist, creating..."
        mkdir -p "${validator_output_dir}"
    fi

    "${AEM_SDK_DISPATCHER_TOOLS}/bin/validator" full -d "${validator_output_dir}" "${config_dir}"

    if [[ $? != 0 ]]; then
        error_log "Dispatcher config validation failed (see messages above)!"
        exit 1
    fi
}

function clear_cache {
    if [[ ${DISP_PRESERVE_CACHE} == 0 ]]; then
        info_log "Removing dispatcher cache"
        rm -rf "$(git_root)/dispatcher/cache"
    else
        warn_log "Dispatcher cache stays untouched - this may lead to unexpected results!"
    fi
}

function docker_run {
    info_log "Starting dispatcher Docker container..."
    info_log "AEM publish URL: http://localhost:45051"
    info_log "Dispatcher URL:  http://localhost:45052"

    "${AEM_SDK_DISPATCHER_TOOLS}/bin/docker_run.sh" "${validator_output_dir}" "${docker_host_domain}:${PUBLISH_PORT}" "${DISP_PORT}"
    if [[ $? != 0 ]]; then
        error_log "Unable to start dispatcher container (see messages above)!"
        exit 1
    fi
}

prerequisites
conf_build
conf_validation
clear_cache
docker_run
