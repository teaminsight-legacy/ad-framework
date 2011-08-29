require 'assert'

module AD::Framework::Patterns::Callbacks

  class BaseTest < Assert::Context
    desc "callbacks pattern"
    setup do
      @structural_class = Factory.structural_class do
        ldap_name "callbacksTestObject"
        attributes :name, :system_flags
        attr_accessor :has_saved

        before_save :set_has_saved_before
        after_save :set_has_saved_after
        before_destroy :set_has_saved_before
        after_destroy :set_has_saved_after
        
        def initialize(*args)
          super
          self.has_saved = nil
        end

        protected

        def set_has_saved_before
          self.has_saved = false
          self.system_flags = 1
        end
        def set_has_saved_after
          self.has_saved = true
        end
      end
      @instance = @structural_class.new({ :name => "test" })
      @mock_connection = mock()
      @instance.stubs(:connection).returns(@mock_connection)
    end
    subject{ @instance }

    should have_instance_methods :create, :update, :destroy

  end

  class CreateTest < BaseTest
    desc "create method"
    setup do
      @instance.fields[:distinguishedname] = @instance.dn
      @instance.fields[:objectclass] = @instance.schema.object_classes.collect(&:ldap_name).compact
      @mock_connection.expects(:add).with({
        :dn => @instance.dn,
        :attributes => @instance.fields.merge({ 'systemflags' => [ "1" ] })
      })
      @instance.expects(:reload)
    end

    should "run the callbacks" do
      assert_nothing_raised{ subject.create }
      assert subject.has_saved
    end
  end

  class UpdateTest < BaseTest
    desc "update method"
    setup do
      @mock_connection.expects(:open).yields(@mock_connection)
      @instance.fields.changes.each do |name, value|
        @mock_connection.expects(:replace_attribute).with(@instance.dn, name, value)
      end
      @mock_connection.expects(:replace_attribute).with(@instance.dn, "systemflags", [ "1" ])
      @instance.expects(:reload)
    end

    should "run the callbacks" do
      assert_nothing_raised{ subject.update }
      assert subject.has_saved
    end
  end

  class DestroyTest < BaseTest
    desc "destroy method"
    setup do
      @mock_connection.expects(:delete).with(@instance.dn)
    end

    should "run the callbacks" do
      assert_nothing_raised{ subject.destroy }
      assert subject.has_saved
    end
  end

end
