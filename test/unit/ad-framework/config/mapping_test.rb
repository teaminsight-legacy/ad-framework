require 'assert'

class AD::Framework::Config::Mapping

  class BaseTest < Assert::Context
    desc "AD::Framework::Config::Mapping"
    setup do
      @mapping = AD::Framework::Config::Mapping.new
    end
    subject{ @mapping }

    should have_instance_methods :[], :[]=, :find, :add

    should "be a kind of Hash" do
      assert_kind_of Hash, subject
    end

    should "lookup an item with it's sym with a call to #[]" do
      subject[:third] = true
      assert_equal true, subject["third"]
      assert_equal true, subject[:third]
    end
    should "lookup an item with it's sym with a call to #find" do
      subject[:fourth] = false
      assert_equal false, subject.find("fourth")
      assert_equal false, subject.find(:fourth)
    end

    should "add an item to it's collection with a call to #[]=" do
      subject["first"] = true
      assert_equal true, subject["first"]
      assert_equal true, subject[:first]
    end
    should "add an item to it's collection with a call to #add" do
      subject.add(:second, false)
      assert_equal false, subject["second"]
      assert_equal false, subject[:second]
    end
  end

end
