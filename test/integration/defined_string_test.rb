require 'assert'
require 'test/integration_helper'

class AD::String

  class BaseTest < Assert::Context
    desc "AD::String"
    setup do
      @attribute_type_class = AD::String
    end
    subject{ @attribute_type_class }

    should "return 'string' with it's key" do
      assert_equal 'string', subject.key
    end
    should "be registered with AD::Framework" do
      registered = AD::Framework.defined_attribute_types[subject.key]
      assert_equal registered, subject
    end
  end

  class InstanceTest < BaseTest
    desc "instance"
    setup do
      @attr_name = "name"
      @name = "someone"
      mock_fields = { @attr_name => [ @name ] }
      mock_object = mock()
      mock_object.stubs(:fields).returns(mock_fields)
      @string = @attribute_type_class.new(mock_object, @attr_name)
    end
    subject{ @string }

    should "return the name with a call to value" do
      assert_equal @name, subject.value
      assert_equal @name, subject.ldap_value
    end
    should "return nil when setting value to nil" do
      subject.value = nil
      assert_nil subject.value
      assert_nil subject.ldap_value
    end

    teardown do
      @string.value = @name
    end
  end

end
