require 'assert'

class AD::Array

  class BaseTest < Assert::Context
    desc "AD::Array"
    setup do
      @attribute_type_class = AD::Array
    end
    subject{ @attribute_type_class }

    should "return 'array' with it's key" do
      assert_equal 'array', subject.key
    end
    should "be registered with AD::Framework" do
      registered = AD::Framework.defined_attribute_types[subject.key]
      assert_equal registered, subject
    end
  end

  class InstanceTest < BaseTest
    desc "instance"
    setup do
      @attr_name = "proxy_addresses"
      @proxy_addresses = [ "a@example.com", "b@example.com" ]
      mock_fields = { @attr_name => @proxy_addresses }
      mock_object = mock()
      mock_object.stubs(:fields).returns(mock_fields)
      mock_object.stubs(:dn).returns("CN=something")
      @array = @attribute_type_class.new(mock_object, @attr_name)
    end
    subject{ @array }

    should "return the name with a call to value" do
      assert_equal @proxy_addresses, subject.value
      assert_equal @proxy_addresses, subject.ldap_value
    end
    should "return an empty array when setting value to nil" do
      subject.value = nil
      assert_empty subject.value
      assert_empty subject.ldap_value
    end

    teardown do
      @array.value = @proxy_addresses
    end
  end

end
