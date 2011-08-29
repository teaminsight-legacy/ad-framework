require 'assert'

class AD::Framework::Schema

  class BaseTest < Assert::Context
    desc "AD::Framework::Schema"
    setup do
      State.preserve
      @structural_class = Factory.structural_class do
        attributes :name
        must_set :name
      end
      @schema = AD::Framework::Schema.new(@structural_class)
    end
    subject{ @schema }

    should have_accessors :ldap_name, :rdn, :attributes, :auxiliary_classes, :klass
    should have_accessors :structural_classes, :mandatory
    should have_instance_methods :treebase, :treebase=, :add_attributes, :add_read_attributes
    should have_instance_methods :add_write_attributes, :add_auxiliary_class

    should "default the rdn to :name" do
      assert_equal :name, subject.rdn
    end
    should "default auxiliary classes to a new array" do
      assert_instance_of Array, subject.auxiliary_classes
      assert_empty subject.auxiliary_classes
    end
    should "default structural classes to a new array" do
      assert_instance_of Array, subject.structural_classes
    end
    should "default attributes to a new set" do
      assert_instance_of Set, subject.attributes
      assert_empty subject.attributes
    end
    should "default mandatory to a new set" do
      assert_instance_of Set, subject.mandatory
      assert_empty subject.mandatory
    end

    teardown do
      State.restore
    end
  end

  class LdapNameWithPrefixTest < BaseTest
    desc "ldap_name method with an ldap prefix set"
    setup do
      @ldap_prefix = "something-"
      @ldap_name = "amazing"
      AD::Framework.config.ldap_prefix = @ldap_prefix
      @schema.ldap_name = @ldap_name
    end

    should "use the ldap_prefix with ldap_name" do
      assert_equal [ @ldap_prefix, @ldap_name ].join, subject.ldap_name
    end
  end

  class LdapNameWithoutPrefixTest < LdapNameWithPrefixTest
    desc "ldap_name method without ldap prefix set"
    setup do
      AD::Framework.config.ldap_prefix = nil
    end

    should "just be the ldap name" do
      assert_equal @ldap_name, subject.ldap_name
    end
  end

  class ObjectClassesTest < BaseTest
    desc "object_classes method"
    setup do
      @structural_classes = [ "structural" ]
      @auxiliary_classes = [ "auxiliary" ]
      @schema.structural_classes = @structural_classes
      @schema.auxiliary_classes = @auxiliary_classes
    end

    should "return all its object classes in the correct order" do
      expected = [
        subject.structural_classes,
        subject.klass,
        subject.auxiliary_classes
      ].flatten
      assert_equal expected, subject.object_classes
    end
  end

  class WithASuperclassSchemaTest < BaseTest
    desc "with a superclass schema"
    setup do
      @child_class = Class.new(@structural_class)
      @schema = AD::Framework::Schema.new(@child_class)
    end
    subject{ @schema }

    should "default attributes to it's parent schema's attributes" do
      assert_equal @structural_class.schema.attributes, subject.attributes
    end
    should "default structural classes to an array with its parent" do
      assert_instance_of Array, subject.structural_classes
      @structural_class.schema.structural_classes.each do |object_class|
        assert_includes object_class, subject.structural_classes
      end
      assert_includes @structural_class, subject.structural_classes
    end
    should "default mandatory to it's parents" do
      assert_equal @structural_class.schema.mandatory, subject.mandatory
    end
  end

  class TreebaseTest < BaseTest
    desc "treebase method"
    setup do
      @schema.treebase = nil
    end

    should "default the treebase to what is configured" do
      assert_equal AD::Framework.config.treebase, subject.treebase
    end

    teardown do
      @schema.treebase = nil
    end
  end

  class WithPartialTreebaseTest < TreebaseTest
    desc "with a partial treebase set"
    setup do
      @treebase = "CN=Incomplete"
      @schema.treebase = @treebase
    end

    should "contact the treebase with what is configured, if it is not included" do
      expected = [ @treebase, AD::Framework.config.treebase ].compact.join(", ")
      assert_equal expected, subject.treebase
    end
  end

  class WithFullTreebaseTest < TreebaseTest
    desc "with a full treebase set"
    setup do
      @treebase = [ "CN=Complete", AD::Framework.config.treebase ].compact.join(", ")
      @schema.treebase = @treebase
    end

    should "return the full treebase" do
      assert_equal @treebase, subject.treebase
    end
  end

  class AttributesMethodTest < BaseTest
    desc "adding attribute methods"
    setup do
      @schema.attributes.clear
    end

    teardown do
      @schema.attributes.clear
    end
  end

  class AddAttributesTest < AttributesMethodTest
    desc "with the add_attributes method"
    setup do
      @attribute_names = [ :name, :display_name, :system_flags ]
      @schema.expects(:add_read_attributes).with(@attribute_names)
      @schema.expects(:add_write_attributes).with(@attribute_names)
    end

    should "call add read and write attributes" do
      assert_nothing_raised{ subject.add_attributes(@attribute_names) }
    end
  end

  class AddReadAttributesTest < AttributesMethodTest
    desc "with the add_read_attributes method"
    setup do
      @attribute_names = [ :display_name ]
      @schema.add_read_attributes(@attribute_names)
      @instance = @structural_class.new
    end

    should "define the reader and then be stored" do
      assert_respond_to :display_name_attribute_type, @instance
      assert_respond_to :display_name, @instance
      assert_includes :display_name, subject.attributes
    end
  end

  class AddWriteAttributesTest < AttributesMethodTest
    desc "with the add_write_attributes method"
    setup do
      @attribute_names = [ :description ]
      @schema.add_read_attributes(@attribute_names)
      @instance = @structural_class.new
    end

    should "define the reader and then be stored" do
      assert_respond_to :description_attribute_type, @instance
      assert_respond_to :description, @instance
      assert_includes :description, subject.attributes
    end
  end

  class AddAuxiliaryClassesTest < BaseTest
    desc "adding auxiliary classes"
    setup do
      @schema.auxiliary_classes.clear
      @auxiliary_class = Factory.auxiliary_class do
        attributes :sam_account_name
        must_set :sam_account_name
      end
      @schema.add_auxiliary_class(@auxiliary_class)
    end

    should "merge the auxiliary classes attributes and store it" do
      assert_includes @auxiliary_class, subject.auxiliary_classes
      @auxiliary_class.schema.attributes.each do |name|
        assert_includes name, subject.attributes
      end
      @auxiliary_class.schema.mandatory.each do |name|
        assert_includes name, subject.mandatory
      end
    end

    teardown do
      @schema.auxiliary_classes.clear
    end
  end
  
  class AddMandatoryTest < BaseTest
    desc "adding mandatory attributes"
    setup do
      @attribute_names = [ :display_name ]
      @schema.add_mandatory(@attribute_names)
    end
    
    should "store the attribute in the mandatory set" do
      @attribute_names.each do |attribute_name|
        assert_includes attribute_name, subject.mandatory
      end
    end    
  end

end
