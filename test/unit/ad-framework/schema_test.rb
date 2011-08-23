require 'assert'

class AD::Framework::Schema

  class BaseTest < Assert::Context
    desc "AD::Framework::Schema"
    setup do
      @class = Class.new(AD::Framework::StructuralClass) do
        attributes :name
      end
      @schema = AD::Framework::Schema.new(@class)
    end
    subject{ @schema }

    should have_accessors :ldap_name, :rdn, :attributes, :auxiliary_classes, :klass
    should have_instance_methods :treebase, :treebase=, :add_attributes, :add_read_attributes
    should have_instance_methods :add_write_attributes, :add_auxiliary_class

    should "default the rdn to :name" do
      assert_equal :name, subject.rdn
    end
    should "default auxiliary classes to a new set" do
      assert_instance_of Set, subject.auxiliary_classes
      assert_empty subject.auxiliary_classes
    end
    should "default attributes to a new set" do
      assert_instance_of Set, subject.attributes
      assert_empty subject.attributes
    end
  end

  class WithASuperclassSchema < BaseTest
    desc "with a superclass schema"
    setup do
      @child = Class.new(@class)
      @schema = AD::Framework::Schema.new(@child)
    end
    subject{ @schema }

    should "default attributes to it's parent schema's attributes" do
      assert_equal @class.schema.attributes, subject.attributes
    end
  end

  class TreebaseTest < BaseTest
    desc "treebase method"
    setup do
      @schema.treebase = nil
    end

    should "default the treebase to what ever is configured" do
      assert_equal AD::Framework.config.treebase, subject.treebase
    end
    should "contact the treebase with what is configured, if it is not included" do
      partial = "CN=Incomplete"
      expected = "#{partial}, #{AD::Framework.config.treebase}"
      subject.treebase = partial

      assert_equal expected, subject.treebase
    end
    should "use the full treebase if it is provided" do
      expected = "CN=Complete, #{AD::Framework.config.treebase}"
      subject.treebase = expected

      assert_equal expected, subject.treebase
    end

    teardown do
      @schema.treebase = nil
    end
  end

  class AddAttributesTest < BaseTest
    desc "adding attribute methods"
    setup do
      @schema.attributes.clear
    end

    should "call add read and write attributes with a call to #add_attributes" do
      names = [ :name, :display_name, :system_flags ]
      subject.expects(:add_read_attributes).with(names)
      subject.expects(:add_write_attributes).with(names)

      assert_nothing_raised do
        subject.add_attributes(names)
      end
    end
    should "define the reader and then store it's symbol with a call to #add_read_attributes" do
      names = [ :display_name ]
      subject.add_read_attributes(names)
      
      assert_respond_to :display_name_attribute_type, @class.new
      assert_respond_to :display_name, @class.new
      assert_includes :display_name, subject.attributes
    end
    should "define the writer and then store it's symbol with a call to #add_write_attributes" do
      names = [ :description ]
      subject.add_read_attributes(names)
      
      assert_respond_to :description_attribute_type, @class.new
      assert_respond_to :description, @class.new
      assert_includes :description, subject.attributes
    end

    teardown do
      @schema.attributes.clear
    end
  end
  
  class AddAuxiliaryClassesTest < BaseTest
    desc "adding auxiliary classes"
    setup do
      @schema.auxiliary_classes.clear
      @auxiliary_class = Module.new do
        include AD::Framework::AuxiliaryClass
        attributes :sam_account_name
      end
    end
    
    should "merge the auxiliary classes attributes and store it" do
      subject.add_auxiliary_class(@auxiliary_class)
      
      assert_includes @auxiliary_class, subject.auxiliary_classes
      @auxiliary_class.schema.attributes.each do |name|
        assert_includes name, subject.attributes
      end
    end
    
    teardown do
      @schema.auxiliary_classes.clear
    end    
  end

end
