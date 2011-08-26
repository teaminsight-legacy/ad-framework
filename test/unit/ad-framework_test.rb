require 'assert'

module AD::Framework

  class BaseTest < Assert::Context
    desc "the AD::Framework module"
    setup do
      @previous_config = AD::Framework.config.dup
      @previous_ad_ldap_config = AD::LDAP.config.dup
      AD::Framework.instance_variable_set("@config", nil)
      AD::LDAP.instance_variable_set("@logger", nil)
      AD::LDAP.instance_variable_set("@adapter", nil)
      AD::LDAP.instance_variable_set("@config", nil)
      @module = AD::Framework
    end
    subject{ @module }

    should have_instance_methods :configure, :config, :connection, :defined_attributes
    should have_instance_methods :register_attributes, :defined_attribute_types
    should have_instance_methods :register_attribute_type, :defined_object_classes
    should have_instance_methods :register_structural_class, :register_auxiliary_class

    should "yield the config with a call to configure" do
      yielded = nil
      subject.configure{|config| yielded = config }

      assert_equal subject.config, yielded
    end
    should "return the config with a call to configure with no block" do
      assert_equal subject.config, subject.configure
    end

    should "return an instance of AD::Framework::Config with a call to #config" do
      assert_instance_of AD::Framework::Config, subject.config
    end
    should "return the config's adapter with #connection" do
      assert_equal subject.config.adapter, subject.connection
    end
    should "return the config's attributes with #defined_attributes" do
      assert_equal subject.config.attributes, subject.defined_attributes
    end
    should "return the config's attribute_types with #defined_attribute_types" do
      assert_equal subject.config.attribute_types, subject.defined_attribute_types
    end
    should "return the config's object_classes with #defined_object_classes" do
      assert_equal subject.config.object_classes, subject.defined_object_classes
    end

    should "store attributes with a call to #register_attributes" do
      definition = { :name => "super_name", :ldap_name => "supersupername", :type => "string" }

      subject.register_attributes([ definition ])
      stored = subject.defined_attributes[:super_name]

      assert_equal definition[:name], stored.name
      assert_equal definition[:ldap_name], stored.ldap_name
      assert_equal definition[:type], stored.type
    end

    should "store an attribute type with a call to #register_attribute_type" do
      attribute_type = mock()
      attribute_type.stubs(:key).returns("super_attribute_type")

      subject.register_attribute_type(attribute_type)
      stored = subject.defined_attribute_types[attribute_type.key]

      assert_equal attribute_type, stored
    end

    should "store a structural class with a call to #register_structural_class" do
      structural_class = mock()
      structural_class.stubs(:ldap_name).returns("super_structural_class")

      subject.register_structural_class(structural_class)
      stored = subject.defined_object_classes[structural_class.ldap_name]

      assert_equal structural_class, stored
    end

    should "store an auxiliary class with a call to #register_auxiliary_class" do
      auxiliary_class = mock()
      auxiliary_class.stubs(:ldap_name).returns("super_auxiliary_class")

      subject.register_auxiliary_class(auxiliary_class)
      stored = subject.defined_object_classes[auxiliary_class.ldap_name]

      assert_equal auxiliary_class, stored
    end

    teardown do
      AD::Framework.instance_variable_set("@config", @previous_config)
      AD::LDAP.instance_variable_set("@config", @previous_ad_ldap_config)
    end
  end

end