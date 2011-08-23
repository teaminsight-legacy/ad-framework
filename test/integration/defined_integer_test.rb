require 'assert'

class AD::Integer

  class BaseTest < Assert::Context
    desc "AD::Integer"
    setup do
      @attribute_type_class = AD::Integer
    end
    subject{ @attribute_type_class }

    should "return 'integer' with it's key" do
      assert_equal 'integer', subject.key
    end
    should "be registered with AD::Framework" do
      registered = AD::Framework.defined_attribute_types[subject.key]
      assert_equal registered, subject
    end
  end

  class InstanceTest < BaseTest
    desc "instance"
    setup do
      @attr_name = "system_flags"
      @system_flags = 123456789
      mock_fields = { @attr_name => [ @system_flags ] }
      mock_object = mock()
      mock_object.stubs(:fields).returns(mock_fields)
      @integer = @attribute_type_class.new(mock_object, @attr_name)
    end
    subject{ @integer }

    should "return the name with a call to value" do
      assert_equal @system_flags, subject.value
      assert_equal @system_flags, subject.ldap_value
    end
    should "return nil when setting value to nil" do
      subject.value = nil
      assert_nil subject.value
      assert_nil subject.ldap_value
    end

    teardown do
      @integer.value = @system_flags
    end
  end

end
