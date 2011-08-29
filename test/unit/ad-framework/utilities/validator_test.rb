require 'assert'

class AD::Framework::Utilities::Validator

  class BaseTest < Assert::Context
    desc "validator"
    setup do
      @structural_class = Factory.structural_class do
        attributes :name
        must_set :name
      end
      @instance = @structural_class.new
      @validator = AD::Framework::Utilities::Validator.new(@instance)
    end
    subject{ @validator }

    should have_accessors :entry

  end
  
  class WithAttributeSetTest < BaseTest
    desc "with attributes set the errors method"
    setup do
      @instance.attributes = { :name => "not nil" }
    end
    
    should "return an empty hash" do
      assert_instance_of Hash, subject.errors
      assert_empty subject.errors
    end
  end
  
  class WithoutAttributeSetTest < BaseTest
    desc "with no attributes set the errors method"
    setup do
      @instance.attributes = { :name => nil }
    end
    
    should "return a hash containing errors for the unset attributes" do
      assert_instance_of Hash, subject.errors
      assert_not_empty subject.errors
      assert_equal "was not set", subject.errors["name"]
    end
  end

end
