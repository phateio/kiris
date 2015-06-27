## Technical
Language: Ruby
Framework: Ruby on Rails

## Requirement
1. Ruby 2.0.0+
2. Rails 4.2.0+

## Installation
```
$ gem install bundle --no-document
$ gem install rails --no-document
```

## Development
```
$ bundle install
$ rake db:create
$ rake db:migrate
$ rake db:seed
$ rails server -e development
```

## Testing
```
$ rake db:test:prepare
$ rake test
```

## Translations
We use [Locale](https://www.localeapp.com/) to manage our translation files. [phateio-i18n](https://www.localeapp.com/projects/6196)

## License
[MIT license](http://opensource.org/licenses/MIT)
