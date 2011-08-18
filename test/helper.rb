# add the current gem root path to the LOAD_PATH
root_path = File.expand_path("../..", __FILE__)
if !$LOAD_PATH.include?(root_path)
  $LOAD_PATH.unshift(root_path)
end

require 'ad-framework'

require 'test/support/attributes'
require 'test/support/attribute_types'
require 'test/support/structural_class'

AD::Framework.configure do |config|
  config.treebase = "DC=example, DC=com"
end
