require 'assert'

class AD::Framework::AttributeType

  class ClassMethodsTest < Assert::Context
    desc "AD::Framework::AttributeType class"
    setup do
      @class = AD::Framework::AttributeType
      @key = "some key"
      @class.key(@key)
    end
    subject{ @class }

    should "set the class's key" do
      assert_equal @key, subject.key
    end
  end

  class DefineMethodsTest < ClassMethodsTest
    setup do
      @attribute = Factory.mock_attribute({ :attribute_type => @class })
      @fields = { @attribute.ldap_name => [ "some value" ] }
      @structural_class = Factory.structural_class
      @instance = @structural_class.new({ :fields => @fields })

      @defined_attr_type_method = "#{@attribute.name}_attribute_type"
      @defined_reader_method = @attribute.name
      @defined_writer_method = "#{@attribute.name}="
    end
    subject{ @instance }
  end

  class DefineAttributeTypeTest < DefineMethodsTest
    desc "define_attribute_type method"
    setup do
      @class.define_attribute_type(@attribute, @instance.class)
      @attribute_type = subject.send(@defined_attr_type_method)
    end

    should "respond to the defined method" do
      assert_respond_to @defined_attr_type_method, subject
    end
    should "return an instance of the attribute type with a call to the defined method" do
      assert_instance_of @class, @attribute_type
      assert_equal subject, @attribute_type.object
      assert_equal @attribute.ldap_name, @attribute_type.attr_ldap_name
    end
  end

  class DefineReaderTest < DefineMethodsTest
    desc "define_reader method"
    setup do
      @class.define_reader(@attribute, @instance.class)
      @reader = subject.send(@defined_reader_method)
      @attribute_type = subject.send(@defined_attr_type_method)
    end

    should "respond to the defined method" do
      assert_respond_to @defined_reader_method, subject
    end
    should "return the attribute type value with a call to the defined method" do
      assert_equal @attribute_type.value, @reader
    end
  end

  class DefineWriterTest < DefineMethodsTest
    desc "define_writer method"
    setup do
      @class.define_writer(@attribute, @instance.class)
      @new_value = "a new value"
      subject.send(@defined_writer_method, @new_value)
      @attribute_type = subject.send(@defined_attr_type_method)
    end

    should "respond to the defined method" do
      assert_respond_to @defined_writer_method, subject
    end
    should "set the attribute type value with a call to the defined method" do
      assert_equal @new_value, @attribute_type.value
    end
  end

  class DefineMethodsAsProcTest < DefineMethodsTest
    setup do
      @class = Factory.attribute_type do
        def self.attribute_type_method(a, n)
          Proc.new{ define_method(n){ true } }
        end
        def self.reader_method(a)
          Proc.new{ define_method(a.name){ true } }
        end
        def self.writer_method(a)
          Proc.new{ define_method("#{a.name}="){|value| value } }
        end
      end
    end
  end

  class AttributeTypeMethodAsProcTest < DefineMethodsAsProcTest
    desc "with an attribute type method as a proc"
    setup do
      @class.define_attribute_type(@attribute, @instance.class)
      @attribute_type = subject.send(@defined_attr_type_method)
    end

    should "respond to the defined method" do
      assert_respond_to @defined_attr_type_method, subject
    end
    should "return true with a call to the defined method" do
      assert_equal true, @attribute_type
    end
  end

  class ReaderMethodAsProcTest < DefineMethodsAsProcTest
    desc "with a reader method as a proc"
    setup do
      @class.define_reader(@attribute, @instance.class)
      @reader = subject.send(@defined_reader_method)
    end
    subject{ @instance }

    should "respond to the defined method" do
      assert_respond_to @defined_reader_method, subject
    end
    should "return true with a call to the defined method" do
      assert_equal true, @reader
    end
  end

  class WriterMethodAsProcTest < DefineMethodsAsProcTest
    desc "with a writer method as a proc"
    setup do
      @class.define_writer(@attribute, @instance.class)
      @writer = subject.send(@defined_writer_method, true)
    end
    subject{ @instance }

    should "respond to the defined method" do
      assert_respond_to @defined_writer_method, subject
    end
    should "return true with a call to the defined method" do
      assert_equal true, @writer
    end
  end

end
