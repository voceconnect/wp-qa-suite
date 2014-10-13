wp-qa-suite
===========

A set of scripts to facilitate the ease of adding syntax checking, unit testing, and code sniffs to a given WordPress project theme or plugin. 

The `wp-qa-suite` provides a consistent way for projects to include continuous integration functionality with something like Travis CI without needing to write BASH statements. Since `wp-qa-suite` can be installed via Composer, this makes updating `wp-qa-suite` for multiple projects easy. 

### Setup

1) Add a `composer.json` file to install the `wp-qa-suite`, example:

```
{
  "name": "you/your-wordpress-plugin",
  "description": "A WordPress plugin to illustrate how to use wp-qa-suite...",
  "license": "GPLv2+",
  "repositories": [
    {
      "type": "git",
      "url": "https://github.com/voceconnect/wp-qa-suite.git"
    }
  ],
  "require-dev": {
    "voceconnect/wp-qa-suite": "~1.0"
  },
  "bin": [
    "bin/wp-qa-syntax",
    "bin/wp-qa-phpunit",
    "bin/wp-qa-codesniff"
  ]
}
```

2) Execute `composer install --dev`

### Integrating with Travis CI

An example `.travis.yml` file:

```
---
language: php

php:
  - 5.5
  - 5.4

env:
  - WP_VERSION=latest

before_script:
  - composer install --dev

script:
  - vendor/bin/wp-qa-syntax
  - vendor/bin/wp-qa-phpunit $WP_VERSION
```

The `.travis.yml` file specifies how the application should be tested in Travis CI. 

In the example within this repository, we want to test our plugin against PHP versions `5.4` and `5.5`:

```
php:
  - 5.5
  - 5.4
```

We can also tests against different versions of WordPress by specifying an environment variable, `WP_VERSION`. The `WP_VERSION` environment variable is passed to the `wp-qa-phpunit` script and used to retrieve the latest or specific version of WordPress. 

```
env:
  - WP_VERSION=latest
```

The `before_script` section of the `.travis.yml` file should be used to 'setup' or 'prep' the test environment, in this case it is used to install Composer dependencies. 

```
before_script:
  - composer install --dev
```

The `script` section of the `.travis.yml` file specifies what should be executed that constitutes "tests" or a "build". If these commands return an exit status that doesn't equal 0, this results in the build "failing". 

```
script:
  - vendor/bin/wp-qa-syntax
  - vendor/bin/wp-qa-phpunit $WP_VERSION
```

In this example, we want to execute a check of all the PHP files for correct syntax, followed by execution of PHP unit tests.
