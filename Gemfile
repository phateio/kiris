# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.6'

# Required for Ruby 3.1+ compatibility with Rails 6.1
gem 'logger'

group :production do
  # Use Lograge for taming Rails' Default Request Logging
  gem 'lograge'
  # Use New Relic for monitoring
  # gem 'newrelic_rpm'
  # Use cloudflare-rails for filtering CloudFlare IPs
  gem 'cloudflare-rails'
end

# Use dotenv for environment variables management
gem 'dotenv-rails'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use pry-rails for pry initializer
gem 'pry-rails'
# Use Redis for in-memory key-value data store
gem 'redis', '~> 4.0'
# Use Rack CORS Middleware for handling CORS
gem 'rack-cors', require: 'rack/cors'
# Use Simple Form as form builder
gem 'simple_form'
# Use Slim for template
gem 'slim-rails'
# Use Ransack as search model
gem 'ransack'
# Use HTTParty as an HTTP client
gem 'httparty'
# Use fog-google for Google Cloud Platform
gem 'fog-google'
# Bootsnap for faster boot times
gem 'bootsnap', '>= 1.4.4', require: false

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.7', '>= 6.1.7.10'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

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

# Rails-assets.org is deprecated, these libraries should be migrated to npm/yarn or vendor/assets
# source 'https://rails-assets.org' do
#   # Use jPlayer for HTML5 Audio
#   gem 'rails-assets-jplayer'
#   # Use NProgress for slim progress bars
#   gem 'rails-assets-nprogress'
#   # Use Intro.js for introduction guide
#   gem 'rails-assets-intro.js'
# end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :windows]
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 4.1.0'
  # Use Better Errors for error pages
  gem 'better_errors'
  # Use binding_of_caller to enable the REPL and local/instance variable inspection
  gem 'binding_of_caller'
  # Use Powder as the app server in development
  gem 'powder'
  # Use pry-remote to binding remote pry in pow
  gem 'pry-remote'
  # Display performance information such as SQL time and flame graphs for each request in your browser
  gem 'rack-mini-profiler', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Use listen to detect file changes
  gem 'listen', '~> 3.3'
  # Use RealFaviconGenerator as favicon generator
  gem 'rails_real_favicon'
  # Use RuboCop for Ruby code analysis
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
end
