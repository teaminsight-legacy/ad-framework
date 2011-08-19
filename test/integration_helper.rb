root_path = File.expand_path("../..", __FILE__)
ldap_config = YAML.load(File.open(File.join(root_path, "private", "ldap.yml")))

FileUtils.mkdir_p(File.join(root_path, "log"))
logger = Log4r::Logger.new("AD::Framework")
logger.add(Log4r::FileOutputter.new('fileOutputter', {
  :filename => File.join(root_path, "log", "test.log"),
  :trunc => false,
  :formatter => Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %m")
}))

AD::Framework.configure do |config|
  config.ldap do |ldap|
    ldap.host = ldap_config[:host]
    ldap.port = ldap_config[:port]
    ldap.encryption = ldap_config[:encryption]
    ldap.auth = ldap_config[:auth]
  end
  config.treebase = ldap_config[:base]
  config.logger = logger
  config.search_size_supported = false
  config.run_commands = false
end
