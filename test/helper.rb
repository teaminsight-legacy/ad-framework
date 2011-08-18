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
  config.ldap do |ldap|
    
  end
  config.treebase = "DC=example, DC=com"
end

=begin
@module.configure do |config|
  config.ldap do |ldap|
    ldap.host = host
    ldap.port = port
    ldap.encryption = encryption
    ldap.auth = auth
  end
  config.logger = logger
  config.search_size_supported = search_size
  config.mappings = mappings
  config.run_commands = run_commands
  config.treebase = treebase
end
=end