require 'assert'

class AD::Framework::Fields

  class BaseTest < Assert::Context
    desc "AD::Framework::Fields"
    setup do
      @fields = AD::Framework::Fields.new({
        :a => "a", :b => "b", :c => "c", :d => "d"
      })
    end
    subject{ @fields }

    should "be a kind of Hash" do
      assert_kind_of Hash, subject
    end
    should "lookup an item with the key as a string with a call to #[]" do
      subject[:a] = true
      assert_equal true, subject["a"]
      assert_equal true, subject[:a]
    end
    should "add an item to it's collection with a call to #[]=" do
      subject["b"] = true
      assert_equal true, subject["b"]
      assert_equal true, subject[:b]
    end

    should "have a custom inspect" do
      key_len = subject.keys.collect(&:size).max + 1
      expected = subject.collect do |(k, v)|
        label = "#{k}:".rjust(key_len, ' ')
        [ label, v.inspect ].join("  ")
      end.join("\n")
      expected = "\n#{expected}"
      assert_equal expected, subject.inspect
    end
  end

  class BuildEntryTest < BaseTest
    desc "build_entry method"
    setup do
      @class = Class.new(AD::Framework::StructuralClass)
      AD::Framework.config.object_classes[:defined] = @class
      @fields["objectclass"] = [ "defined" ]
    end
    subject{ @fields }

    should "return an instance of the class matching the mapping in the objectclass" do
      entry = subject.build_entry
      assert_instance_of @class, entry
      assert_equal @fields, entry.fields
    end

    teardown do
      AD::Framework.config.object_classes.delete(:defined)
    end
  end

  class InvalidBuildEntryTest < BaseTest
    desc "build_entry method with an invalid objectclass"
    setup do
      @fields["objectclass"] = [ "notdefined" ]
    end
    subject{ @fields }

    should "raise an error when the object class does not exist" do
      assert_raises(AD::Framework::StructuralClassNotDefined) do
        subject.build_entry
      end
    end
  end

end
