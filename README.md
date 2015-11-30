## Technical
- Language: Ruby
- Framework: Ruby on Rails

## Requirement
1. Ruby 2.2.3
2. Rails 4.2.x

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
Open http://localhost:3000/

## Testing
```
$ rake db:test:prepare
$ rake test
```

## Translations
We use [phateio-i18n@Locale](https://www.localeapp.com/projects/6196) to manage our translation files.

Everyone is welcome to help correct, improve, or complete the translations.

## License
[MIT license](http://opensource.org/licenses/MIT)
