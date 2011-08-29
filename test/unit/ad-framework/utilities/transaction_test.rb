require 'assert'

class AD::Framework::Utilities::Transaction

  class BaseTest < Assert::Context
    desc "a transaction"
    setup do
      @structural_class = Factory.structural_class do
        attr_accessor :count, :before_called, :after_called, :main_called
        before_create :set_before_called
        after_create :set_after_called

        def initialize(*args)
          super
          self.count = 0
          self.before_called = nil
          self.main_called = nil
          self.after_called = nil
        end

        protected

        def set_before_called
          self.count += 1
          self.before_called = self.count
        end
        def set_after_called
          self.count += 1
          self.after_called = self.count
        end
      end
      @instance = @structural_class.new
      @transaction = AD::Framework::Utilities::Transaction.new(:create, @instance) do
        self.count += 1
        self.main_called = self.count
      end
    end
    subject{ @transaction }
    
    should have_instance_methods :run
    
    should "call the before callbacks, then the block, then the after callbacks" do
      subject.run
      assert_equal 1, @instance.before_called
      assert_equal 2, @instance.main_called
      assert_equal 3, @instance.after_called
    end
  end

end
