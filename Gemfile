source "http://rubygems.org"

# Specify your gem's dependencies in ad-framework.gemspec
gemspec

gem 'rake', "~>0.9.2"
gem "ad-ldap", :git => "git@github.com:teaminsight/ad-ldap.git", :branch => "master"

if RUBY_VERSION =~ /^1.8/
  gem 'rcov'
else
  gem 'simplecov', :require => false
end