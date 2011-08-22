require 'assert'

class AD::Framework::Config::AttributeDefinition

  class BaseTest < Assert::Context
    desc "AD::Framework::Config::AttributeDefinition"
    setup do
      @attr = { :name => "something", :ldap_name => "some", :type => "string" }
      @definition = AD::Framework::Config::AttributeDefinition.new(@attr)
    end
    subject{ @definition }

    should have_accessors :name, :ldap_name, :type

    should "have set the name correctly" do
      assert_equal @attr[:name], subject.name
    end
    should "have set the ldap_name correctly" do
      assert_equal @attr[:ldap_name], subject.ldap_name
    end
    should "have set the type correctly" do
      assert_equal @attr[:type], subject.type
    end
  end

end
