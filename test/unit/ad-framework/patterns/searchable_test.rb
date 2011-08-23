require 'assert'

module AD::Framework::Patterns::Searchable

  class BaseTest < Assert::Context
    desc "AD::Framework::Searchable"
    setup do
      @class = Class.new do
        include AD::Framework::Patterns::Searchable
      end
      @instance = @class.new
    end
    subject{ @instance }

    should have_instance_methods :reload
    should have_class_methods :find, :first, :all

    should_eventually "reload an entry with a call to #reload" do
      # TODO
    end
    should_eventually "return the first entry with a call to #first" do
      # TODO
    end
    should_eventually "return a collection of entries with a call to #all" do
      # TODO
    end
    should_eventually "return an entry with a matching dn with a call to #find" do
      # TODO
    end
    should_eventually "return an entry with a matching rdn with a call to #find" do
      # TODO
    end
  end

end
