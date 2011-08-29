require 'assert'

module AD::Framework::Patterns::HasSchema

  class BaseTest < Assert::Context
    desc "AD::Framework::Patterns::HasSchema"
    setup do
      @structural_class = Factory.structural_class do
        treebase "CN=Something, DC=example, DC=com"
        attributes :name, :display_name
      end
      @instance = @structural_class.new({ :name => "someone", :display_name => "Someone" })
    end
    subject{ @instance }

    should have_instance_methods :schema, :dn, :attributes, :attributes=
    should have_class_methods :schema, :ldap_name, :treebase, :rdn, :attributes
    should have_class_methods :read_attributes, :write_attributes

    should "return it's class's schema wtih a call to #schema" do
      assert_equal subject.class.schema.klass, subject.schema.klass
    end
    should "return a hash of the attributes and their values with a call to #attributes" do
      expected = subject.schema.attributes.inject({}) do |h, a|
        h.merge({ a.to_sym => subject.send(a) })
      end
      assert_equal expected, subject.attributes
    end
  end

  class DnTest < BaseTest
    desc "dn method"
    setup do
      @distinguished_name = "CN=distinguishedname, #{subject.schema.treebase}"
      @dn = "CN=dn, #{subject.schema.treebase}"
      @built_dn = "CN=#{subject.send(subject.schema.rdn)}, #{subject.schema.treebase}"
      @instance.fields[:distinguishedname] = @distinguished_name
      @instance.fields[:dn] = @dn
    end
    subject{ @instance }

    should "return the distinguished name field" do
      assert_equal @distinguished_name, subject.dn
    end
  end

  class DnWithoutDistinguishedNameTest < DnTest
    desc "without the distinguishedname field"
    setup do
      @instance.fields[:distinguishedname] = nil
    end

    should "return the dn field" do
      assert_equal @dn, subject.dn
    end
  end

  class DnWithNoFieldsTest < DnWithoutDistinguishedNameTest
    desc "and without the dn field"
    setup do
      @instance.fields[:dn] = nil
    end

    should "return a concatenation of the rdn field and the treebase" do
      assert_equal @built_dn, subject.dn
    end
  end

  class SetObjectAttributesTest < BaseTest
    desc "setting attributes"
    setup do
      @new_attributes = { :name => "amazing", :display_name => "Amazing" }
      @instance.attributes = @new_attributes
    end

    should "set multiple attributes" do
      assert_equal @new_attributes[:name], subject.name
      assert_equal @new_attributes[:display_name], subject.display_name
    end
  end

  class SetAttributesWithInvalidTest < BaseTest
    desc "setting attributes with ignored key/values"
    setup do
      @new_attributes = { :something => "something" }
    end

    should "be ignored" do
      new_attributes = @new_attributes
      assert_nothing_raised{ subject.attributes = new_attributes }
    end
  end

end
