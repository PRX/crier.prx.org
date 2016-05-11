source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.6'
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
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'rdoc', '~> 4.2.2'

gem 'rake'

# Use postgresql as the database for Active Record
gem 'pg'

gem 'addressable'

# for rss feeds
gem 'feedjira'

# for pings
gem 'xmlrpc-rack_server', '~> 0.0.2'

gem 'excon'
gem 'faraday'
gem 'fastimage'
gem 'dotenv-rails'
gem 'shoryuken'
gem 'announce'
gem 'paranoia', '~> 2.0'
gem 'actionpack-action_caching'

# paging
gem 'kaminari'

gem "responders"
gem "roar-rails"
gem 'hal_api-rails', '~> 0.2.4'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Pry is an IRB alternative and runtime developer console
  gem 'pry-rails'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :development do
  # Quiet Assets turns off Rails asset pipeline log
  gem 'quiet_assets'

  # HighLine is a higher level command-line oriented interface
  gem 'highline'

  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-bundler'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'minitest-spec-rails'
  gem 'factory_girl_rails'
  gem 'webmock'
  gem 'minitest-reporters', require: false
  gem "codeclimate-test-reporter", require: false
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end

group :production do
  # Include 'rails_12factor' gem to send logging to stdout and serve assets in production mode
  gem 'rails_12factor'

  # Use puma as the HTTP server
  gem 'puma'
end
