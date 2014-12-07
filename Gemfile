source 'https://rubygems.org'
gemspec

require 'rbconfig'

group :development, :test do
  gem 'rake', require: false
  gem 'rspec', '~> 3.1'
  gem 'aruba', require: false
end

group :development do
  gem 'guard-bundler', '~> 2.0.0', '>= 2.0.1', require: false
  gem 'guard-rspec', require: false
  gem 'guard-cucumber', require: false
  gem 'transpec', require: false
end
