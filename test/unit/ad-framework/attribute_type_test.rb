require 'assert'

class AD::Framework::AttributeType

  class BaseTest < Assert::Context
    desc "AD::Framework::AttributeType"
    setup do
      @class = AD::Framework::AttributeType
      @ldap_name = "some"
      @fields = { @ldap_name => [ "value" ] }
      @object = Factory.mock_structural_class_instance({ :fields => @fields })
      @attribute_type = @class.new(@object, @ldap_name)
    end
    subject{ @attribute_type }

    should have_accessors :object, :attr_ldap_name, :value, :ldap_value
    should have_instance_methods :value_from_field, :inspect
    should have_class_methods :key, :define_attribute_type, :attribute_type_method
    should have_class_methods :define_reader, :reader_method, :define_writer, :writer_method

    should "have set the object correctly" do
      assert_equal @object, subject.object
    end
    should "have set the attr_ldap_name correctly" do
      assert_equal @ldap_name, subject.attr_ldap_name
    end
    should "have set the value correctly" do
      assert_equal subject.value_from_field, subject.value
    end
    should "return the value from the object's fields with #value_from_field" do
      assert_equal @fields[@ldap_name].first, subject.value_from_field
    end

    should "return a custom inspect" do
      expected = "#<#{subject.class} attr_ldap_name: #{subject.attr_ldap_name.inspect}, "
      expected += "ldap_value: #{subject.ldap_value.inspect}, "
      expected += "object: #{@object.class} - #{@object.dn.inspect}, "
      expected += "value: #{subject.value.inspect}>"
      assert_equal expected, subject.inspect
    end
  end

  class CreatedWithAValueTest < BaseTest
    desc "created with a value"
    setup do
      @value = "amazing"
      @attribute_type = @class.new(@object, @ldap_name, @value)
    end

    should "set the value from that arg" do
      assert_equal @value, subject.value
    end
  end

  class SetValueTest < BaseTest
    desc "setting the value"
    setup do
      @value = "amazing"
      @attribute_type.value = "amazing"
    end

    should "set the value and ldap_value" do
      assert_equal @value, subject.value
      assert_equal @value, subject.ldap_value
    end
  end

  class SetLdapValueTest < BaseTest
    desc "setting the ldap value"
    setup do
      @ldap_value = "amazing"
      @attribute_type.ldap_value = @ldap_value
    end

    should "set the ldap value and the object's fields" do
      assert_equal @ldap_value, subject.ldap_value
      assert_equal [ @ldap_value ], subject.object.fields[subject.attr_ldap_name]
    end
  end
  
  class SetLdapValueWithArrayTest < BaseTest
    desc "setting the ldap value with an array"
    setup do
      @ldap_value = [ 1, "2" ]
      @attribute_type.ldap_value = @ldap_value
    end
    
    should "convert all objects to strings for object's fields with a call to #ldap_value=" do
      assert_equal @ldap_value, subject.ldap_value
      expected = @ldap_value.collect(&:to_s)
      assert_equal expected, subject.object.fields[subject.attr_ldap_name]
    end
  end

end
