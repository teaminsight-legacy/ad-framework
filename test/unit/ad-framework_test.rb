require 'assert'

module AD::Framework

  class BaseTest < Assert::Context
    desc "the AD::Framework module"
    setup do
      @module = AD::Framework.dup
    end
    subject{ @module }

    should have_instance_methods :configure, :config, :connection

    should "return an instance of AD::Framework::Config" do
      assert_instance_of AD::Framework::Config, subject.config
    end
    should "return the config's adapter with #connection" do
      assert_equal subject.config.adapter, subject.connection
    end

  end

  class ConfigureTest < BaseTest
    desc "configured"
    setup do
      host = @host = "127.0.0.1"
      port = @port = 389
      encryption = @encryption = :simple_tls
      auth = @auth = { :username => "domain\\account", :password => "something" }
      logger = @logger = OpenStruct.new(:fake_logger => true)
      search_size = @search_size = false
      mappings = @mappings = { :dn => "distinguishedname" }
      run_commands = @run_commands = false
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
      end
    end
    subject{ @module.config }

    should "intialize AD::LDAP's adapter correctly" do
      adapter = subject.ldap.adapter
      assert_equal @host, adapter.host
      assert_equal @port, adapter.port
      assert_equal @encryption, adapter.instance_variable_get("@encryption")[:method]
      assert_equal @auth[:username], adapter.instance_variable_get("@auth")[:username]
      assert_equal @auth[:password], adapter.instance_variable_get("@auth")[:password]
    end
    should "set AD::LDAP's logger" do
      assert_kind_of AD::LDAP::Logger, subject.logger
      assert_equal @logger, subject.logger.logger
    end
    should "set the other config options" do
      assert_equal @search_size, subject.search_size_supported
      assert_equal @mappings, subject.mappings
      assert_equal @run_commands, subject.run_commands
    end

  end

end