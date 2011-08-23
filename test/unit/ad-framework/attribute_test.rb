require 'assert'

class AD::Framework::Attribute

  class BaseTest < Assert::Context
    desc "AD::Framework::Attribute"
    setup do
      @definition = mock()
      @definition.stubs(:name).returns("test_attr")
      @definition.stubs(:ldap_name).returns("testattr")
      @definition.stubs(:type).returns("awesomestring")
      AD::Framework.config.attributes[@definition.name] = @definition
      @attribute_type = mock()
      @attribute_type.stubs(:key).returns("awesomestring")
      AD::Framework.config.attribute_types[@attribute_type.key] = @attribute_type
      @attribute = AD::Framework::Attribute.new(@definition.name.to_s)
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
    
    should "call define_reader on it's attribute type with a call to #define_reader" do
      klass = Class.new
      subject.attribute_type.expects(:define_reader).with(subject, klass)
      
      assert_nothing_raised do
        subject.define_reader(klass)
      end
    end
    should "call define_writer on it's attribute type with a call to #define_writer" do
      klass = Class.new
      subject.attribute_type.expects(:define_writer).with(subject, klass)
      
      assert_nothing_raised do
        subject.define_writer(klass)
      end
    end
    
    should "raise an exception when a new attribute is created with out a definition" do
      assert_raises(AD::Framework::AttributeNotDefined) do
        AD::Framework::Attribute.new("notdefined")
      end
    end
    should "raise an exception when a new attribute is created with an invalid type" do
      assert_raises(AD::Framework::AttributeTypeNotDefined) do
        definition = mock()
        definition.stubs(:name).returns("not_defined")
        definition.stubs(:ldap_name).returns("notdefined")
        definition.stubs(:type).returns("notdefined")
        AD::Framework.config.attributes[definition.name] = definition
        AD::Framework::Attribute.new(definition.name)
      end
    end

    teardown do
      AD::Framework.config.attribute_types.delete(@attribute_type.key.to_sym)
      AD::Framework.config.attributes.delete(@definition.name.to_sym)
    end
  end

end
