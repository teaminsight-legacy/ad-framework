require 'assert'

class AD::Framework::Config

  class BaseTest < Assert::Context
    desc "AD::Frameowrk::Config"
    setup do
      @previous_config = AD::LDAP.config.dup
      AD::LDAP.instance_variable_set("@logger", nil)
      AD::LDAP.instance_variable_set("@adapter", nil)
      AD::LDAP.instance_variable_set("@config", nil)
      @config = AD::Framework::Config.new
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
    should "pass a block to AD::LDAP configure with a call to #ldap" do
      ldap_block = ::Proc.new{ true }
      AD::LDAP.expects(:configure).with(&ldap_block)
      assert_nothing_raised do
        subject.ldap(&ldap_block)
      end
    end

    should "return the adapter's logger with a call to #logger" do
      subject.adapter.config.logger = mock()
      assert_equal subject.adapter.logger, subject.logger
    end
    should "set the adapter's logger with a call to #logger=" do
      logger = mock()
      subject.logger = logger
      assert_equal logger, subject.adapter.config.logger
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

    should "add an attribute definition to the attributes with a call to #add_attribute" do
      attr = { :name => "something", :ldap_name => "s", :type => "string" }
      definition = AD::Framework::Config::AttributeDefinition.new(attr)
      subject.add_attribute(attr)

      assert_equal attr[:ldap_name], subject.mappings[attr[:name]]
      assert definition, subject.attributes[attr[:name]]
    end
    should "add an attribute type to the attribute_types with a call to #add_attribute_type" do
      attribute_type = mock()
      attribute_type.stubs(:key => "something")
      subject.add_attribute_type(attribute_type)

      assert_equal attribute_type, subject.attribute_types[attribute_type.key]
    end
    should "add an object class to the object_classes with a call to #add_object_classes" do
      object_class = mock()
      object_class.stubs(:ldap_name => "something")
      subject.add_object_class(object_class)

      assert_equal object_class, subject.object_classes[object_class.ldap_name]
    end

    teardown do
      AD::LDAP.instance_variable_set("@logger", nil)
      AD::LDAP.instance_variable_set("@adapter", nil)
      AD::LDAP.instance_variable_set("@config", @previous_config)
    end
  end

end
