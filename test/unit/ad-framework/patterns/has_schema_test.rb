require 'assert'

module AD::Framework::Patterns::HasSchema

  class ClassMethodsTest < Assert::Context
    desc "AD::Framework::Patterns::HasSchema class"
    setup do
      mod = @module = AD::Framework::Patterns::HasSchema
      @class = Class.new(AD::Framework::StructuralClass) do
        include mod

        attr_accessor :name, :display_name
      end
    end
    subject{ @class }

    should "return an instance of AD::Framework::Schema with a call to #schema" do
      assert_instance_of AD::Framework::Schema, subject.schema
    end
    should "set the schema's ldap name with a call to #ldap_name" do
      new_value = "awesomeness"
      subject.ldap_name new_value
      expected = [ AD::Framework.config.ldap_prefix, new_value ].compact.join
      assert_equal expected, subject.schema.ldap_name
    end
    should "set the schema's treebase with a call to #treebase" do
      new_value = "CN=container"
      subject.treebase new_value
      assert_match new_value, subject.schema.treebase
    end
    should "set the schema's rdn with a call to #rdn" do
      new_value = "name"
      subject.rdn new_value
      assert_equal new_value, subject.schema.rdn
    end
    should "add attributes to the schema with a call to #attributes" do
      attrs = [ :name, :display_name ]
      subject.schema.expects(:add_attributes).with(attrs)

      assert_nothing_raised do
        subject.attributes *attrs
      end
    end
    should "add read attributes to the schema with a call to #read_attributes" do
      attrs = [ :name, :display_name ]
      subject.schema.expects(:add_read_attributes).with(attrs)

      assert_nothing_raised do
        subject.read_attributes *attrs
      end
    end
    should "add write attributes to the schema with a call to #write_attributes" do
      attrs = [ :name, :display_name ]
      subject.schema.expects(:add_write_attributes).with(attrs)

      assert_nothing_raised do
        subject.write_attributes *attrs
      end
    end
  end

  class BaseTest < ClassMethodsTest
    desc "AD::Framework::Patterns::HasSchema"
    setup do
      @class.schema.rdn = :name
      @class.schema.treebase = "CN=Something, DC=example, DC=com"
      @class.schema.attributes = [ :name, :display_name ]
      @instance = @class.new
      @instance.name = "someone"
      @instance.display_name = "Someone"
    end
    subject{ @instance }

    should have_instance_methods :schema, :dn, :attributes, :attributes=
    should have_class_methods :schema, :ldap_name, :treebase, :rdn, :attributes
    should have_class_methods :read_attributes, :write_attributes

    should "return it's class's schema wtih a call to #schema" do
      assert_equal subject.class.schema.klass, subject.schema.klass
    end
    should "return use the fields then a concatenation of rdn and treebase with a call to #dn" do
      expected_distinguishedname = "CN=full not expected, #{subject.schema.treebase}"
      subject.fields[:distinguishedname] = expected_distinguishedname
      expected_dn = "CN=not expected, #{subject.schema.treebase}"
      subject.fields[:dn] = expected_dn
      expected = "CN=#{subject.send(subject.schema.rdn)}, #{subject.schema.treebase}"

      assert_equal expected_distinguishedname, subject.dn
      subject.fields[:distinguishedname] = nil
      assert_equal expected_dn, subject.dn
      subject.fields[:dn] = nil
      assert_equal expected, subject.dn
    end
    should "return a hash of the attributes and their values with a call to #attributes" do
      expected = subject.schema.attributes.inject({}) do |h, a|
        h.merge({ a.to_sym => subject.send(a) })
      end
      assert_equal expected, subject.attributes
    end
    should "set multiple attributes with a call to #attributes=" do
      new_attrs = { :name => "amazing", :display_name => "Amazing" }
      subject.attributes = new_attrs

      assert_equal new_attrs[:name], subject.name
      assert_equal new_attrs[:display_name], subject.display_name
    end
    should "ignore any attributes not defined on the schema" do
      new_attrs = { :something => "something" }
      assert_nothing_raised{ subject.attributes = new_attrs }
    end
  end

end
