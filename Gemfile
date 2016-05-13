source 'https://rubygems.org'

# Ruby version
ruby '2.3.1'

group :production do
  # Use Rails 12factor for Heroku
  gem 'rails_12factor'
  # Use Lograge for taming Rails' Default Request Logging
  gem 'lograge'
  # Use New Relic for monitoring
  gem 'newrelic_rpm'
  # Use cloudflare-rails for filtering CloudFlare IPs
  gem 'cloudflare-rails'
end

# Use dotenv for environment variables management
gem 'dotenv-rails'
# Use Puma as the app server
gem 'puma'
# Use pry-rails for pry initializer
gem 'pry-rails'
# Use Redis for in-memory key-value data store
gem 'redis'
# Use redis-rails for Rails cache store
gem 'redis-rails'
# Use Simple Form as form builder
gem 'simple_form'
# Use Slim for template
gem 'slim-rails'
# Use Rollbar as an error tracking service
gem 'rollbar'
# Use Ransack as search model
gem 'ransack'
# Use HTTParty as an HTTP client
gem 'httparty'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.5'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use rails-i18n as I18n solution
gem 'rails-i18n'
# Use Kaminari as paginator
gem 'kaminari'
# Use Nokogiri as HTML parser
gem 'nokogiri'
# Use Redcarpet as Markdown parser
gem 'redcarpet'
# Use CodeRay for syntax highlighting
gem 'coderay'

# Use amazon-ecs for Amazon Product Advertising API
gem 'amazon-ecs'
# Use http_accept_language help detect the users preferred language
gem 'http_accept_language'

# Use Foundation as UI framework
gem 'foundation-rails'
# Use Font Awesome for vector icons
gem 'font-awesome-sass'

source 'https://rails-assets.org' do
  # Use jPlayer for HTML5 Audio
  gem 'rails-assets-jplayer'
  # Use NProgress for slim progress bars
  gem 'rails-assets-nprogress'
  # Use Intro.js for introduction guide
  gem 'rails-assets-intro.js'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'
  # Use Better Errors for error pages
  gem 'better_errors'
  # Use binding_of_caller to enable the REPL and local/instance variable inspection
  gem 'binding_of_caller'
  # Use Powder as the app server in development
  gem 'powder'
  # Use pry-remote to binding remote pry in pow
  gem 'pry-remote'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Use Quiet Assets to mute assets pipeline log messages
  gem 'quiet_assets'
  # Use RealFaviconGenerator as favicon generator
  gem 'rails_real_favicon'
end
