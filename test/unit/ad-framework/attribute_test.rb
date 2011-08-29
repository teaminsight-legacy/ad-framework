require 'assert'

class AD::Framework::Attribute

  class BaseTest < Assert::Context
    desc "AD::Framework::Attribute"
    setup do
      @class = AD::Framework::Attribute
      @definition = Factory.attribute_definition
      AD::Framework.config.attributes[@definition.name] = @definition
      @attribute_type = Factory.mock_attribute_type
      AD::Framework.config.attribute_types[@attribute_type.key] = @attribute_type
      @attribute = @class.new(@definition.name.to_s)
    end
    subject{ @attribute }

    should have_accessors :name, :ldap_name, :attribute_type
    should have_instance_methods :define_reader, :define_writer

    should "set the name correctly" do
      assert_equal @definition.name, subject.name
    end
    should "set the ldap name correctly" do
      assert_equal @definition.ldap_name, subject.ldap_name
    end
    should "set the attribute type correctly" do
      assert_equal @attribute_type, subject.attribute_type
    end

    teardown do
      AD::Framework.config.attribute_types.delete(@attribute_type.key.to_sym)
      AD::Framework.config.attributes.delete(@definition.name.to_sym)
    end
  end

  class DefineReaderTest < BaseTest
    desc "define_reader method"
    setup do
      @structural_class = Factory.structural_class
      @attribute.attribute_type.expects(:define_reader).with(@attribute, @structural_class)
    end

    should "call define_reader on it's attribute type" do
      assert_nothing_raised{ subject.define_reader(@structural_class) }
    end
  end

  class DefineWriterTest < BaseTest
    desc "define_writer method"
    setup do
      @structural_class = Factory.structural_class
      @attribute.attribute_type.expects(:define_writer).with(@attribute, @structural_class)
    end

    should "call define_writer on it's attribute type with a call to #define_writer" do
      assert_nothing_raised{ subject.define_writer(@structural_class) }
    end
  end

  class CreatedWithoutADefinitionTest < BaseTest
    desc "created without a definition"

    should "raise an exception" do
      assert_raises(AD::Framework::AttributeNotDefined){ @class.new("not_defined") }
    end
  end

  class CreatedWithABadAttributeTypeTest < BaseTest
    desc "created with a bad attribute type test"
    setup do
      @definition = Factory.attribute_definition({ :type => "not_defined" })
      AD::Framework.config.attributes[@definition.name] = @definition
    end

    should "raise an exception" do
      assert_raises(AD::Framework::AttributeTypeNotDefined){ @class.new(@definition.name) }
    end

    teardown do
      AD::Framework.config.attributes.delete(@definition.name.to_sym)
    end
  end

end
