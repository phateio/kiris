[![Build Status](https://travis-ci.org/phateio/kiris.svg?branch=master)](https://travis-ci.org/phateio/kiris)
[![Code Climate](https://codeclimate.com/github/phateio/kiris/badges/gpa.svg)](https://codeclimate.com/github/phateio/kiris)
[![Test Coverage](https://codeclimate.com/github/phateio/kiris/badges/coverage.svg)](https://codeclimate.com/github/phateio/kiris/coverage)

## Getting Started

1. Install Bundler and Rails at the command prompt if you haven't yet:

        $ gem install bundle --no-document
        $ gem install rails --no-document

2. Install the gem dependencies using bundler:

        $ bundle install

3. Initialize the database if you haven't yet:

        $ bundle exec rake db:create
        $ bundle exec rake db:migrate
        $ bundle exec rake db:seed

4. Start the web server:

        $ rails server

5. Using a browser, go to `http://localhost:3000` and you'll see the home page.

## Test
        $ bundle exec rake db:test:prepare
        $ bundle exec rake test

## Translations
We use [phateio-i18n@Locale](https://www.localeapp.com/projects/6196) to manage our translation files.

Everyone is welcome to help correct, improve, or complete the translations.

## License
Phate Radio is released under the [MIT License](https://opensource.org/license/MIT).
