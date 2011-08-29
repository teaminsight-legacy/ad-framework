require 'assert'

module AD::Framework::Patterns::Validations

  class BaseTest < Assert::Context
    desc "the validations pattern"
    setup do
      @structural_class = Factory.structural_class do
        ldap_name "validationsTestObject"
        attributes :name, :system_flags
        must_set :name, :system_flags
      end
      @instance = @structural_class.new({ :name => "test", :system_flags => 1 })
      @mock_connection = mock()
      @instance.stubs(:connection).returns(@mock_connection)
    end
    subject{ @instance }

    should have_accessors :errors
    should have_instance_methods :valid?, :create, :update

    should "default errors to a new hash" do
      assert_equal({}, subject.errors)
    end
  end

  class WithErrorsTest < BaseTest
    desc "with errors"
    setup do
      @instance.attributes = { :name => nil, :system_flags => nil }
      @instance.valid?
    end

    should "have added errors for the attributes to th errors hash" do
      assert_not_empty subject.errors
      subject.schema.attributes.each do |attribute_name|
        assert_includes attribute_name.to_s, subject.errors.keys
      end
    end
  end

  class WithNoErrorsTest < BaseTest
    desc "with no errors"
    setup do
      @instance.valid?
    end

    should "have no key/values in the errors hash" do
      assert_empty subject.errors
    end
  end

  class CreateInvalidTest < WithErrorsTest
    desc "create method"
    setup do
      @instance.expects(:valid?)
    end

    should "check if the entry is valid and return if it added it" do
      result = nil
      assert_nothing_raised{ result = subject.create }
      assert_equal false, result
    end
  end

  class UpdateInvalidTest < WithErrorsTest
    desc "update method"
    setup do
      @instance.expects(:valid?)
    end

    should "check if the entry is valid and return if it updated it" do
      result = nil
      assert_nothing_raised{ result = subject.update }
      assert_equal false, result
    end
  end

  class CreateValidTest < WithNoErrorsTest
    desc "create method"
    setup do
      @mock_connection.expects(:add).with({
        :dn => @instance.dn,
        :attributes => @instance.fields
      })
      @instance.expects(:reload)
    end

    should "check if the entry is valid and return if it added it" do
      result = nil
      assert_nothing_raised{ result = subject.create }
      assert_equal true, result
    end
  end

  class UpdateValidTest < WithNoErrorsTest
    desc "create method"
    setup do
      @mock_connection.expects(:open).yields(@mock_connection)
      @instance.fields.changes.each do |name, value|
        @mock_connection.expects(:replace_attribute).with(@instance.dn, name, value)
      end
      @instance.expects(:reload)
    end

    should "check if the entry is valid and return if it added it" do
      result = nil
      assert_nothing_raised{ result = subject.update }
      assert_equal true, result
    end
  end

end
