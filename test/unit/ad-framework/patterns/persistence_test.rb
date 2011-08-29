require 'assert'

module AD::Framework::Patterns::Persistence

  class BaseTest < Assert::Context
    desc "the persistence pattern"
    setup do
      @structural_class = Factory.structural_class do
        ldap_name "persistenceTestObject"
        attributes :name, :system_flags
      end
      @instance = @structural_class.new({ :name => "test", :system_flags => 1 })
      @mock_connection = mock()
      @instance.stubs(:connection).returns(@mock_connection)
    end
    subject{ @instance }

    should have_instance_methods :new_entry?, :save, :create, :update, :destroy
    should have_class_methods :create

    should "return true with #new_entry?" do
      assert_equal true, subject.new_entry?
    end
    should "call #create with #save" do
      subject.expects(:create)
      assert_nothing_raised{ subject.save }
    end
  end

  class WithDistinguishedNameFieldTest < BaseTest
    desc "with a distinguishedname field set"
    setup do
      @instance.fields[:distinguishedname] = "distinguishedname"
    end

    should "return false with #new_entry?" do
      assert_equal false, subject.new_entry?
    end
    should "call #create with #save" do
      subject.expects(:update)
      assert_nothing_raised{ subject.save }
    end
  end

  class WithDnFieldTest < BaseTest
    desc "with a dn field set"
    setup do
      @instance.fields[:dn] = "dn"
    end

    should "return false with #new_entry?" do
      assert_equal false, subject.new_entry?
    end
    should "call #create with #save" do
      subject.expects(:update)
      assert_nothing_raised{ subject.save }
    end
  end

  class CreateObjectTest < BaseTest
    desc "create method"
    setup do
      @set_dn = @instance.dn
      fields = @instance.fields.dup
      fields[:objectclass] = @instance.schema.object_classes.collect(&:ldap_name).compact
      fields[:distinguishedname] = @set_dn
      @set_attributes = fields.to_hash
      @mock_connection.expects(:add).with({ :dn => @set_dn, :attributes => @set_attributes })
      @instance.expects(:reload)
    end

    should "call add on it's connection with the fields, including dn and objectclass" do
      assert_nothing_raised{ @instance.create }
    end
  end

  class UpdateObjectTest < BaseTest
    desc "update method"
    setup do
      @instance.fields[:dn] = @instance.dn
      @instance.attributes = { :name => "new name", :system_flags => 12 }
      @mock_connection.expects(:open).yields(@mock_connection)
      @instance.fields.changes.each do |name, value|
        @mock_connection.expects(:replace_attribute).with(@instance.dn, name, value)
      end
      @instance.expects(:reload)
    end

    should "call replace attribute for every changed field" do
      assert_nothing_raised{ subject.update }
    end
  end

  class DestroyObjectTest < BaseTest
    desc "destroy method"
    setup do
      @instance.fields[:dn] = @instance.dn
      @mock_connection.expects(:delete).with(@instance.dn)
    end

    should "call delete on the connection" do
      assert_nothing_raised{ subject.destroy }
    end
  end

  class CreateClassMethodTest < Assert::Context
    desc "create on the class"
    setup do
      @structural_class = Factory.structural_class do
        ldap_name "persistenceClassTestObject"
        attributes :name, :system_flags
      end
      @attributes = { :name => "from class", :system_flags => 5 }
      mock_entry = mock()
      @structural_class.expects(:new).returns(mock_entry).with(@attributes)
      mock_entry.expects(:create)
    end
    subject{ @structural_class }

    should "call create on a new entry build with attributes passed to it" do
      attributes = @attributes
      assert_nothing_raised{ subject.create(attributes) }
    end
  end

end
