require 'assert'

class AD::Framework::AttributeType

  class BaseTest < Assert::Context
    desc "AD::Framework::AttributeType"
    setup do
      @ldap_name = "some"
      @fields = { @ldap_name => [ "some value" ] }
      @object = mock()
      @object.stubs(:dn).returns("CN=some object, DC=example, DC=com")
      @object.stubs(:fields).returns(@fields)
      @attribute_type = AD::Framework::AttributeType.new(@object, @ldap_name)
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

    should "initialized with a third arg should set the value from that arg" do
      value = "amazing"
      attribute_type = AD::Framework::AttributeType.new(@object, @ldap_name, value)

      assert_equal value, attribute_type.value
    end

    should "return the value from the object's fields with a call to #value_from_field" do
      assert_equal @fields[@ldap_name].first, subject.value_from_field
    end

    should "set the value and ldap_value with a call to #value=" do
      expected = "amazing"
      subject.value = expected

      assert_equal expected, subject.value
      assert_equal expected, subject.ldap_value
    end
    should "set the ldap value and the object's fields with a call to #ldap_value=" do
      expected = "amazing"
      subject.ldap_value = expected

      assert_equal expected, subject.ldap_value
      assert_equal [ expected ], subject.object.fields[subject.attr_ldap_name]
    end
    should "convert all objects to strings for object's fields with a call to #ldap_value=" do
      expected = [ 1, "2" ]
      subject.ldap_value = expected

      assert_equal expected, subject.ldap_value
      assert_equal expected.collect(&:to_s), subject.object.fields[subject.attr_ldap_name]
    end

    should "return a custom inspect" do
      expected = "#<#{subject.class} attr_ldap_name: #{subject.attr_ldap_name.inspect}, "
      expected += "ldap_value: #{subject.ldap_value.inspect}, "
      expected += "object: #{@object.class} - #{@object.dn.inspect}, "
      expected += "value: #{subject.value.inspect}>"
      assert_equal expected, subject.inspect
    end
  end

  class ClassMethodsTest < Assert::Context
    desc "AD::Framework::AttributeType class"
    setup do
      @class = AD::Framework::AttributeType
    end
    subject{ @class }

    should "set the class's key with a call to #key and an arg" do
      key = "some key"
      subject.key(key)

      assert_equal key, subject.key
    end

    teardown do
      @class.instance_variable_set("@key", nil)
    end

    def attribute_mock
      attribute = mock()
      attribute.stubs(:name).returns("some_name")
      attribute.stubs(:ldap_name).returns("somename")
      attribute.stubs(:attribute_type).returns(@class)
      attribute
    end
    def object_mock(klass = nil)
      object = klass ? klass.new : mock()
      object.stubs(:fields).returns((@fields || {}))
      object.stubs(:dn).returns("a dn")
      object
    end
  end

  class DefineAttributeTypeTest < ClassMethodsTest
    desc "define_attribute_type method"
    setup do
      @attribute = self.attribute_mock
      @fields = { @attribute.ldap_name => [ "some value" ] }
      @define_class = Class.new
      @class.define_attribute_type(@attribute, @define_class)
      @defined_method = "#{@attribute.name}_attribute_type"

      @instance = self.object_mock(@define_class)
    end
    subject{ @instance }

    should "respond to the defined method" do
      assert_respond_to @defined_method, subject
    end
    should "return an instance of the attribute type with a call to the defined method" do
      attribute_type = subject.send(@defined_method)
      assert_instance_of @class, attribute_type
      assert_equal subject, attribute_type.object
      assert_equal @attribute.ldap_name, attribute_type.attr_ldap_name
    end
  end

  class AttributeTypeMethodAsProcTest < ClassMethodsTest
    desc "with an attribute type method as a proc"
    setup do
      @attribute = self.attribute_mock
      @class = Class.new(AD::Framework::AttributeType) do

        def self.attribute_type_method(attribute, method_name)
          Proc.new do
            define_method(method_name){ true }
          end
        end

      end
      @define_class = Class.new
      @class.define_attribute_type(@attribute, @define_class)
      @defined_method = "#{@attribute.name}_attribute_type"

      @instance = self.object_mock(@define_class)
    end
    subject{ @instance }

    should "respond to the defined method" do
      assert_respond_to @defined_method, subject
    end
    should "return true with a call to the defined method" do
      attribute_type = subject.send(@defined_method)
      assert_equal true, attribute_type
    end
  end

  class DefineReaderTest < ClassMethodsTest
    desc "define_reader method"
    setup do
      @attribute = self.attribute_mock
      @fields = { @attribute.ldap_name => [ "some value" ] }
      @define_class = Class.new
      @class.define_reader(@attribute, @define_class)

      @instance = self.object_mock(@define_class)
    end
    subject{ @instance }

    should "respond to the defined method" do
      assert_respond_to @attribute.name, subject
    end
    should "return the attribute type value with a call to the defined method" do
      reader = subject.send(@attribute.name)
      attribute_type = subject.send("#{@attribute.name}_attribute_type")
      assert_equal attribute_type.value, reader
    end
  end

  class ReaderMethodAsProc < ClassMethodsTest
    desc "with a reader method as a proc"
    setup do
      @attribute = self.attribute_mock
      @class = Class.new(AD::Framework::AttributeType) do

        def self.reader_method(attribute)
          Proc.new do
            define_method(attribute.name){ true }
          end
        end

      end
      @define_class = Class.new
      @class.define_reader(@attribute, @define_class)

      @instance = self.object_mock(@define_class)
    end
    subject{ @instance }

    should "respond to the defined method" do
      assert_respond_to @attribute.name, subject
    end
    should "return true with a call to the defined method" do
      reader = subject.send(@attribute.name)
      assert_equal true, reader
    end
  end

  class DefineWriterTest < ClassMethodsTest
    desc "define_writer method"
    setup do
      @attribute = self.attribute_mock
      @fields = { @attribute.ldap_name => [ "some value" ] }
      @define_class = Class.new
      @class.define_writer(@attribute, @define_class)
      @defined_method = "#{@attribute.name}="

      @instance = self.object_mock(@define_class)
    end
    subject{ @instance }

    should "respond to the defined method" do
      assert_respond_to @defined_method, subject
    end
    should "set the attribute type value with a call to the defined method" do
      new_value = "something"
      writer = subject.send(@defined_method, new_value)
      attribute_type = subject.send("#{@attribute.name}_attribute_type")
      assert_equal new_value, attribute_type.value
    end
  end

  class WriterMethodAsProc < ClassMethodsTest
    desc "with a writer method as a proc"
    setup do
      @attribute = self.attribute_mock
      @class = Class.new(AD::Framework::AttributeType) do

        def self.writer_method(attribute)
          Proc.new do
            define_method("#{attribute.name}="){ true }
          end
        end

      end
      @define_class = Class.new
      @class.define_writer(@attribute, @define_class)
      @defined_method = "#{@attribute.name}="

      @instance = self.object_mock(@define_class)
    end
    subject{ @instance }

    should "respond to the defined method" do
      assert_respond_to @defined_method, subject
    end
    should "return true with a call to the defined method" do
      writer = subject.send(@defined_method)
      assert_equal true, writer
    end
  end

end
