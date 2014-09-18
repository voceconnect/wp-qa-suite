#!/bin/bash

#######################################
# setup test environment to run PHP
# unit tests with required wordpress
# testing libraries and configs
#######################################

set -euo pipefail
IFS=$'\n\t'

##
# CONSTANTS
##
readonly DB_NAME="wp_test"
readonly DB_USER="travis"
readonly DB_PASS=""
readonly DB_HOST="localhost"
readonly WP_TESTS_DIR="/tmp/wordpress-tests-lib"
readonly WP_CORE_DIR="/tmp/wordpress"
readonly PHPCS_DIR="/tmp/phpcs"
readonly WPCS_DIR="/tmp/wpcs"

#######################################
# validates and sets constants based
# on provided arguments
# Globals:
#   WP_ARCHIVE
# Arguments:
#   $1 - wp_version
# Returns:
#   Nothing
#######################################
function check_arguments() {
  local wp_version=${1:-}
  if [[ -z "${wp_version}" ]]; then
    echo "usage: $0 <wp_version>"
    exit 1
  else
    if [[ "${wp_version}" == "latest" ]]; then
      readonly WP_ARCHIVE="latest"
    else
      readonly WP_ARCHIVE="wordpress-${wp_version}"
    fi
  fi
}

#######################################
# retrieves latest or specified version
# of wordpress into WP_CORE_DIR
# Globals:
#   WP_CORE_DIR
#   WP_ARCHIVE
# Arguments:
#   None
# Returns:
#   Nothing
#######################################
function install_wordpress() {
  mkdir -p "${WP_CORE_DIR}"

  wget -nv -O "/tmp/wordpress.tar.gz" \
    "http://wordpress.org/${WP_ARCHIVE}.tar.gz"
  tar --strip-components=1 -zxmf "/tmp/wordpress.tar.gz" -C "${WP_CORE_DIR}"
}

#######################################
# setup of wordpress unit test
# includes and configuration
# Globals:
#   WP_TESTS_DIR
#   WP_CORE_DIR
#   DB_NAME
#   DB_USER
#   DB_PASS
#   DB_HOST
# Arguments:
#   None
# Returns:
#   Nothing
#######################################
function install_test_suite() {
  if [[ $(uname -s) == 'Darwin' ]]; then
    local ioption='-i ""'
  else
    local ioption='-i'
  fi

  mkdir -p "${WP_TESTS_DIR}"
  cd "${WP_TESTS_DIR}"
  svn co --quiet http://develop.svn.wordpress.org/trunk/tests/phpunit/includes/

  wget -nv -O wp-tests-config.php \
    http://develop.svn.wordpress.org/trunk/wp-tests-config-sample.php
  sed $ioption "s:dirname( __FILE__ ) . '/src/':'${WP_CORE_DIR}/':" \
    wp-tests-config.php
  sed $ioption "s/youremptytestdbnamehere/${DB_NAME}/" wp-tests-config.php
  sed $ioption "s/yourusernamehere/${DB_USER}/" wp-tests-config.php
  sed $ioption "s/yourpasswordhere/${DB_PASS}/" wp-tests-config.php
  sed $ioption "s|localhost|${DB_HOST}|" wp-tests-config.php
}

function install_php_codesniffer() {
  mkdir -p "${PHPCS_DIR}"

  wget -nv -O "/tmp/phpcs.tar.gz" \
    "https://github.com/squizlabs/PHP_CodeSniffer/archive/master.tar.gz"
  tar --strip-components=1 -zxmf "/tmp/phpcs.tar.gz" -C "${PHPCS_DIR}"
}

function install_wordpress_coding_standards() {
  mkdir -p "${WPCS_DIR}"

  wget -nv -O "/tmp/wpcs.tar.gz" \
    "https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards/archive/master.tar.gz"
  tar --strip-components=1 -zxmf "/tmp/wpcs.tar.gz" -C "${WPCS_DIR}"

  "${PHPCS_DIR}/scripts/phpcs" --config-set installed_paths "${WPCS_DIR}"
}

#######################################
# creates DB_NAME database for tests
# Globals:
#   DB_NAME
#   DB_USER
#   DB_PASS
#   DB_HOST
# Arguments:
#   None
# Returns:
#   Nothing
#######################################
function setup_database() {
  mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" \
    --user="${DB_USER}" \
    --pass="${DB_PASS}" \
    --host="${DB_HOST}"
}

function main() {
  check_arguments "$@"

  install_wordpress
  install_test_suite
  install_php_codesniffer
  install_wordpress_coding_standards
  setup_database
}

main "$@"