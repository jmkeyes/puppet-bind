source 'https://rubygems.org'

group :rake, :test do
  gem 'rake',                   '~> 10.3.2'
  gem 'rspec',                  '~> 2.0'
  gem 'rspec-puppet',           '~> 1.0.1'
  gem 'puppetlabs_spec_helper', '~> 0.8.2'
end

group :rake, :development do
  gem 'travis',            '~> 1.7.2'
  gem 'travis-lint',       '~> 2.0.0'
  gem 'puppet-lint',       '~> 1.1.0'
  gem 'puppet-syntax',     '~> 1.3.0'
  gem 'puppet-blacksmith', '~> 3.0.2'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '~> 3.7.2', :require => false
end

