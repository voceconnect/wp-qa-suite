#!/bin/bash

readonly PHPCS_IGNORE='tests/*,vendor/*'

function execute_php_syntax_check() {
  echo "performing PHP lint checks..."
  find . -name "*.php" -print0 | xargs -0 -n1 -P4 php -l
}

function install_php_test_helpers() {
  git clone https://github.com/php-test-helpers/php-test-helpers.git /tmp/php-test-helpers
  cd /tmp/php-test-helpers

  (
    phpize
    ./configure --enable-test-helpers
    make
    sudo make install
  )

  cd -
}

function execute_wordpress_code_sniffer() {
  echo "executing PHP Code Sniffer..."
  if [[ -e "phpcs.ruleset.xml" ]]; then
    local wpcs_standard="phpcs.ruleset.xml"
  else
    local wpcs_standard="WordPress-Core"
  fi


  "${PHPCS_DIR}/scripts/phpcs" \
    --standard="${wpcs_standard}" \
    --ignore="${PHPCS_IGNORE}" \
    $(find . -name '*.php')
}