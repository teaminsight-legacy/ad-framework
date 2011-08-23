if RUBY_VERSION =~ /^1.9/ && ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start
end

require 'log4r'
require 'mocha'
require 'yaml'

if RUBY_VERSION =~ /^1.9/
  YAML::ENGINE.yamler= 'syck'
end

# add the current gem root path to the LOAD_PATH
root_path = File.expand_path("../..", __FILE__)
if !$LOAD_PATH.include?(root_path)
  $LOAD_PATH.unshift(root_path)
end
require 'ad-framework'

class Assert::Context
  include Mocha::API
end
