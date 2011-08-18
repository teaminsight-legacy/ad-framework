require 'assert'

module AD::Framework

  class BaseTest < Assert::Context
    desc "the AD::Framework module"
    setup do
      @module = AD::Framework.dup
    end
    subject{ @module }

    should have_instance_methods :configure, :config, :connection

    should "return an instance of AD::Framework::Config" do
      assert_instance_of AD::Framework::Config, subject.config
    end
    should "return the config's adapter with #connection" do
      assert_equal subject.config.adapter, subject.connection
    end

  end

end