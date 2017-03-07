source 'https://rubygems.org'

# Padrino supports Ruby version 1.9 and later
# ruby '2.3.1'

# Distribute your app as a gem
# gemspec

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'

# Component requirements
gem 'mysql2'
gem 'sequel'

# Test requirements
gem 'rspec', :group => 'test'
gem 'rack-test', :require => 'rack/test', :group => 'test'

gem 'jwt'
gem 'bcrypt'
# gem 'grape-cancan'
gem 'padrino-cancan'

group :development do
  gem "capistrano", "~> 3.7"
end

# Padrino Stable Gem
gem 'padrino', '0.13.3.3'
gem 'rest-client'

# gem 'padrino-warden', :github => 'jondot/padrino-warden'
# gem 'warden-jwt', :github => 'sgsaravana/warden-jwt'

gem 'guard'
gem 'guard-rspec', require: false

gem 'grape'
# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core support gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.13.3.3'
# end
