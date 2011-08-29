if RUBY_VERSION =~ /^1.9/ && ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start
end

require 'assert'
require 'log4r'
require 'mocha'
require 'yaml'

if RUBY_VERSION =~ /^1.9/
  YAML::ENGINE.yamler= 'syck'
end

root_path = File.expand_path("../..", __FILE__)
ldap_config = YAML.load(File.open(File.join(root_path, "test", "ldap.yml")))

FileUtils.mkdir_p(File.join(root_path, "log"))
TEST_LOGGER = Log4r::Logger.new("AD::Framework")
TEST_LOGGER.add(Log4r::FileOutputter.new('fileOutputter', {
  :filename => File.join(root_path, "log", "test.log"),
  :trunc => false,
  :formatter => Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %m")
}))

# add the current gem root path to the LOAD_PATH
root_path = File.expand_path("../..", __FILE__)
if !$LOAD_PATH.include?(root_path)
  $LOAD_PATH.unshift(root_path)
end
require 'ad-framework'

require 'test/support/schema/attributes'
require 'test/support/schema/attribute_types'
require 'test/support/schema/auxiliary_classes'
require 'test/support/schema/structural_classes'

require 'test/support/state'
require 'test/support/factory'
require 'test/support/seed'

class Assert::Context
  include Mocha::API
end

AD::Framework.configure do |config|
  config.ldap do |ldap|
    ldap.host = ldap_config[:host]
    ldap.port = ldap_config[:port]
    ldap.encryption = ldap_config[:encryption]
    ldap.auth = ldap_config[:auth]
  end
  config.treebase = ldap_config[:base]
  config.logger = TEST_LOGGER
  config.search_size_supported = false
  config.run_commands = true
  config.ldap_prefix = "adtest-"
end

Assert.suite.setup do
  puts "\nSeeding the ldap database..."
  time = Benchmark.measure{ Seed.up }
  puts ("Done (%.6f seconds)" % [ time.real ])
end

Assert.suite.teardown do
  puts "\nCleaning up the ldap database..."
  time = Benchmark.measure{ Seed.down }
  puts ("Done (%.6f seconds)\n\n" % [ time.real ])
end

