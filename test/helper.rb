require 'log4r'
require 'mocha'

# add the current gem root path to the LOAD_PATH
root_path = File.expand_path("../..", __FILE__)
if !$LOAD_PATH.include?(root_path)
  $LOAD_PATH.unshift(root_path)
end

require 'ad-framework'

class Assert::Context
  include Mocha::API
end
