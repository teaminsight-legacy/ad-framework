require 'assert'

module AD::Framework::AuxiliaryClass

  class BaseTest < Assert::Context
    desc "AD::Framework::AuxiliaryClass"
    setup do
      @module = AD::Framework::AuxiliaryClass
    end
    subject{ @module }

  end

  class IncludedTest < BaseTest
    setup_once do
      RandomAuxiliaryClass = Module.new do
        include AD::Framework::AuxiliaryClass
        ldap_name "random_auxiliary_class"
      end
    end
    setup do
      included_module = @included_module = RandomAuxiliaryClass
      @class = Class.new(AD::Framework::StructuralClass) do
        include included_module
      end
    end
    subject{ @included_module }

    should have_instance_methods :schema, :ldap_name, :treebase, :rdn, :attributes, :read_attributes
    should have_instance_methods :write_attributes

    should "have defined an included method on the class it was included on" do
      assert_respond_to :included, subject
    end
    should "have added the included module to the class's schema it was included on" do
      assert_includes subject, @class.schema.auxiliary_classes
    end
  end

end
