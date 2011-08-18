require 'assert'

class DefinedAttributeTypeTest < Assert::Context
  desc "the defined attribute type"

  class StringTest < DefinedAttributeTypeTest
    desc "AD::String"
    setup do
      @attribute_type_class = AD::String
    end
    subject{ @attribute_type_class }

    should "be registered with AD::Framework" do
      registered = AD::Framework.defined_attribute_types[subject.key]
      assert_equal registered, subject
    end
  end
  
  class IntegerTest < DefinedAttributeTypeTest
    desc "AD::Integer"
    setup do
      @attribute_type_class = AD::Integer
    end
    subject{ @attribute_type_class }

    should "be registered with AD::Framework" do
      registered = AD::Framework.defined_attribute_types[subject.key]
      assert_equal registered, subject
    end
  end

end
