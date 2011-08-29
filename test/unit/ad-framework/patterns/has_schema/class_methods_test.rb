require 'assert'

module AD::Framework::Patterns::HasSchema

  class ClassMethodsTest < Assert::Context
    desc "AD::Framework::Patterns::HasSchema class"
    setup do
      @module = AD::Framework::Patterns::HasSchema
      @structural_class = Factory.structural_class do
        attributes :name, :display_name
      end
    end
    subject{ @structural_class }

    should "return an instance of AD::Framework::Schema with #schema" do
      assert_instance_of AD::Framework::Schema, subject.schema
    end
  end

  class SetLdapNameTest < ClassMethodsTest
    desc "setting ldap name"
    setup do
      @new_value = "awesomeness"
      @structural_class.ldap_name(@new_value)
    end

    should "set the schema's ldap name" do
      assert_match @new_value, subject.schema.ldap_name
    end
  end

  class SetTreebaseTest < ClassMethodsTest
    desc "setting treebase"
    setup do
      @new_value = "CN=container"
      @structural_class.treebase(@new_value)
    end

    should "set the schema's treebase with a call to #treebase" do
      assert_match @new_value, subject.schema.treebase
    end
  end

  class SetRdnTest < ClassMethodsTest
    desc "setting rdn"
    setup do
      @new_value = "name"
      @structural_class.rdn(@new_value)
    end

    should "set the schema's rdn with a call to #rdn" do
      assert_equal @new_value, subject.schema.rdn
    end
  end

  class SetAttributesTest < ClassMethodsTest
    desc "setting attributes"
    setup do
      @values = [ :name, :display_name ]
      @structural_class.schema.expects(:add_attributes).with(@values)
    end

    should "add attributes to the schema" do
      values = @values
      assert_nothing_raised{ subject.attributes(*values) }
    end
  end

  class SetReadAttributesTest < ClassMethodsTest
    desc "setting read attributes"
    setup do
      @values = [ :name, :display_name ]
      @structural_class.schema.expects(:add_read_attributes).with(@values)
    end

    should "add read attributes to the schema" do
      values = @values
      assert_nothing_raised{ subject.read_attributes(*values) }
    end
  end

  class SetWriteAttributesTest < ClassMethodsTest
    desc "setting write attributes"
    setup do
      @values = [ :name, :display_name ]
      @structural_class.schema.expects(:add_write_attributes).with(@values)
    end

    should "add write attributes to the schema" do
      values = @values
      assert_nothing_raised{ subject.write_attributes(*values) }
    end
  end

  class SetMustSetTest < ClassMethodsTest
    desc "setting mandatory attributes"
    setup do
      @values = [ :name ]
      @structural_class.schema.expects(:add_mandatory).with(@values)
    end

    should "add mandatory attributes to the schema" do
      values = @values
      assert_nothing_raised{ subject.must_set(*values) }
    end
  end

end
