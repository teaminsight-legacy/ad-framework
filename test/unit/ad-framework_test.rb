require 'assert'

module AD::Framework

  class BaseTest < Assert::Context
    desc "the AD::Framework module"
    setup do
      State.preserve
      @module = AD::Framework
    end
    subject{ @module }

    should have_instance_methods :configure, :config, :connection, :defined_attributes
    should have_instance_methods :register_attributes, :defined_attribute_types
    should have_instance_methods :register_attribute_type, :defined_object_classes
    should have_instance_methods :register_structural_class, :register_auxiliary_class

    should "return an instance of AD::Framework::Config with #config" do
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

    teardown do
      State.restore
    end
  end

  class ConfigureTest < BaseTest
    desc "configure method"
    setup do
      yielded = nil
      @module.configure{|config| yielded = config }
      @yielded = yielded
    end

    should "yield the config" do
      assert_equal subject.config, @yielded
    end
    should "return the config with no block" do
      assert_equal subject.config, subject.configure
    end
  end

  class RegisterAttributesTest < BaseTest
    desc "register_attributes method"
    setup do
      @definition = { :name => "super_name", :ldap_name => "supersupername", :type => "string" }
      @module.register_attributes([ @definition ])
      @stored = @module.defined_attributes[:super_name]
    end
    subject{ @stored }

    should "store attributes" do
      assert_equal @definition[:name], subject.name
      assert_equal @definition[:ldap_name], subject.ldap_name
      assert_equal @definition[:type], subject.type
    end
  end

  class RegisterAttributeTypeTest < BaseTest
    desc "register_attribute_type method"
    setup do
      @attribute_type = mock()
      @attribute_type.stubs(:key).returns("super_attribute_type")
      @module.register_attribute_type(@attribute_type)
      @stored = @module.defined_attribute_types[@attribute_type.key]
    end
    subject{ @stored }

    should "store an attribute type" do
      assert_equal @attribute_type, subject
    end
  end

  class RegisterStructuralClassTest < BaseTest
    desc "register_structural_class method"
    setup do
      @structural_class = mock()
      @structural_class.stubs(:ldap_name).returns("super_structural_class")
      @module.register_structural_class(@structural_class)
      @stored = @module.defined_object_classes[@structural_class.ldap_name]
    end
    subject{ @stored }

    should "store a structural class" do
      assert_equal @structural_class, @stored
    end
  end

  class RegisterAuxiliaryClassTest < BaseTest
    desc "register_auxiliary_class method"
    setup do
      @auxiliary_class = mock()
      @auxiliary_class.stubs(:ldap_name).returns("super_auxiliary_class")
      @module.register_auxiliary_class(@auxiliary_class)
      @stored = @module.defined_object_classes[@auxiliary_class.ldap_name]
    end
    subject{ @stored }

    should "store an auxiliary class" do
      assert_equal @auxiliary_class, subject
    end
  end

end