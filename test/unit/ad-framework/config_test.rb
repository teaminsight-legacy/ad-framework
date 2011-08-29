require 'assert'

class AD::Framework::Config

  class BaseTest < Assert::Context
    desc "AD::Frameowrk::Config"
    setup do
      State.preserve
      @config = AD::Framework::Config.new
      @logger = mock()
      @config.adapter.config.logger = @logger
    end
    subject{ @config }

    should have_accessors :attributes, :attribute_types, :object_classes, :ldap_prefix
    should have_accessors :logger, :search_size_supported, :mappings, :run_commands, :treebase
    should have_instance_methods :ldap, :adapter, :add_attribute, :add_attribute_type
    should have_instance_methods :add_object_class

    [ :mappings, :attributes, :attribute_types, :object_classes ].each do |attr|
      should "return a mapping with a call to ##{attr}" do
        assert_instance_of AD::Framework::Config::Mapping, subject.send(attr)
      end
    end
    should "include a basic mapping for dn" do
      assert_equal subject.mappings[:dn], "distinguishedname"
    end
    should "return AD::LDAP with a call to #ldap" do
      assert_equal AD::LDAP, subject.ldap
    end

    should "return the adapter's logger with a call to #logger" do
      assert_equal subject.adapter.logger, subject.logger
    end
    should "set the adapter's logger with a call to #logger=" do
      assert_equal @logger, subject.adapter.config.logger
    end

    [ :search_size_supported, :mappings, :run_commands, :treebase ].each do |attr|
      should "return the adapter's config value for #{attr.inspect} with a call to ##{attr}" do
        subject.adapter.config.send("#{attr}=", mock())
        assert_equal subject.adapter.config.send(attr), subject.send(attr)
      end
      should "set the adapter's config value for #{attr.inspect} with a call to ##{attr}=" do
        value = mock()
        subject.send("#{attr}=", value)
        assert_equal value, subject.adapter.config.send(attr)
      end
    end

    teardown do
      State.restore
    end
  end

  class LdapTest < BaseTest
    desc "ldap method"
    setup do
      @ldap_block = ::Proc.new{ true }
      AD::LDAP.expects(:configure).with(&@ldap_block)
    end

    should "pass a block to AD::LDAP configure" do
      assert_nothing_raised{ subject.ldap(&@ldap_block) }
    end
  end

  class LdapPrefixTest < BaseTest
    desc "setting the ldap prefix"
    setup do
      @prefix = "something-"
      @structural_class = Factory.structural_class
      @config.add_object_class(@structural_class)
      @config.ldap_prefix = @prefix
    end

    should "re-register any object classes" do

      stored = subject.object_classes["#{@prefix}#{@structural_class.ldap_name}"]
      assert_equal @structural_class, stored
    end
  end

  class AddAttributeTest < BaseTest
    desc "add_attribute method"
    setup do
      @definition = { :name => "test_attr", :ldap_name => "testattr", :type => "string" }
      @config.add_attribute(@definition)
    end

    should "add an attribute definition to the attributes" do
      assert_equal @definition[:ldap_name], subject.mappings[@definition[:name]]
      assert @definition, subject.attributes[@definition[:name]]
    end
  end

  class AddAttributeTypeTest < BaseTest
    desc "add_attribute_type method"
    setup do
      @attribute_type = Factory.mock_attribute_type
      @config.add_attribute_type(@attribute_type)
    end

    should "add an attribute type to the attribute_types" do
      assert_equal @attribute_type, subject.attribute_types[@attribute_type.key]
    end
  end

  class AddObjectClass < BaseTest
    desc "add_object_class method"
    setup do
      @object_class = Factory.structural_class
      @config.add_object_class(@object_class)
    end

    should "add an object class to the object_classes" do
      assert_equal @object_class, subject.object_classes[@object_class.ldap_name]
    end
  end

end
