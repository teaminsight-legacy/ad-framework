require 'assert'

class AD::Framework::Utilities::EntryBuilder

  class BaseTest < Assert::Context
    desc "AD::Framework::Utilities::EntryBuilder"
    setup do
      @class = Class.new(AD::Framework::StructuralClass) do
        ldap_name "somethingAmazing"
        attributes :name
      end
      AD::Framework.register_structural_class(@class)
      @ldap_entry = { "objectclass" => [ @class.schema.ldap_name ] }
      @entry_builder = AD::Framework::Utilities::EntryBuilder.new(@ldap_entry)
    end
    subject{ @entry_builder }

    should have_accessors :ldap_entry, :entry, :fields
    should have_instance_methods :reload, :build

    should "have build a fields object from the ldap entry" do
      assert_instance_of AD::Framework::Fields, subject.fields
    end

    teardown do
      AD::Framework.defined_object_classes.delete(@class.ldap_name.to_sym)
    end
  end

  class BuildTest < BaseTest
    desc "entry builder building a new entry"
    subject{ @entry_builder.entry }

    should "be a kind of the class in its object class" do
      assert_instance_of @class, subject
    end
    should "have set the fields on the entry to its" do
      assert_equal @entry_builder.fields, subject.fields
    end
  end

  class ReloadTest < BaseTest
    desc "entry builder reloading an entry"
    setup do
      @entry = @entry_builder.entry
      @entry.fields["something"] = "amazing"
      @entry.name = "something new"
      @entry_builder = AD::Framework::Utilities::EntryBuilder.new(@ldap_entry, {
        :reload => @entry
      })
    end
    subject{ @entry }

    should "have reset it's fields" do
      assert_not_equal "amazing", subject.fields["something"]
      assert_nil subject.fields["something"]
    end
    should "have reset it's attributes" do
      assert_not_equal "something new", subject.name
      assert_nil subject.name
    end
  end

  class WithLinkedAuxiliaryClassesTest < BaseTest
    desc "entry builder building a new entry with linked aux classes"
    setup do
      @auxiliary_class = Module.new do
        include AD::Framework::AuxiliaryClass
        ldap_name "displayIt"
        attributes :display_name
      end
      AD::Framework.register_auxiliary_class(@auxiliary_class)
      @ldap_entry = { 
        "objectclass" => [ @auxiliary_class.schema.ldap_name, @class.schema.ldap_name ]
      }
      @entry_builder = AD::Framework::Utilities::EntryBuilder.new(@ldap_entry)
    end
    subject{ @entry_builder.entry }

    should "be a kind of the class in its object class" do
      assert_instance_of @class, subject
    end
    should "have set the fields on the entry to its" do
      assert_equal @entry_builder.fields, subject.fields
    end
    should "have add the auxiliary class to the entry" do
      assert_includes @auxiliary_class, subject.schema.auxiliary_classes
      assert_includes :display_name, subject.schema.attributes
      assert_respond_to :display_name, subject
    end
    
    teardown do
      AD::Framework.defined_object_classes.delete(@auxiliary_class.ldap_name.to_sym)
    end
  end

  class UndefinedObjectClassTest < Assert::Context
    desc "AD::Framework::Utilities::EntryBuilder"
    setup do
      @ldap_entry = { "objectclass" => [ "notdefinedatall" ] }
    end
    subject{ @ldap_entry }

    should "raise an object class not defined exception" do
      assert_raises(AD::Framework::ObjectClassNotDefined) do
        AD::Framework::Utilities::EntryBuilder.new(@ldap_entry)
      end
    end
  end

end
