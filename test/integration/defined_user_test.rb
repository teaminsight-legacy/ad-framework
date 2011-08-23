require 'assert'

class AD::User

  class BaseTest < Assert::Context
    desc "user"
    setup do
      @structural_class = AD::User
    end
    subject{ @structural_class }

    should "be registered with AD::Framework's config" do
      assert_equal AD::Framework.config.object_classes[subject.ldap_name], subject
    end
  end
  
  class SchemaTest < BaseTest
    desc "schema"
    setup do
      @ldap_name = "user"
      @rdn = :name
      @treebase = [ "CN=Users", AD::Framework.config.treebase ].join(", ")
      @attrs = [ :name, :system_flags, :display_name, :description, :proxy_addresses, 
        :sam_account_name ]
      @schema = @structural_class.schema
    end
    subject{ @schema }

    should "store the ldap name defined on the class" do
      assert_equal @ldap_name, subject.ldap_name
    end
    should "store the rdn defined on the class" do
      assert_equal @rdn, subject.rdn
    end
    should "store the treebase defined on the class" do
      assert_equal @treebase, subject.treebase
    end
    should "contain all the attributes defined on the class" do
      @attrs.each do |attr|
        assert_includes attr, subject.attributes
      end
    end
  end

  class InstanceTest < BaseTest
    desc "instance"
    setup do
      @proxy_addresses = [ "developer@example.com", "dev@example.com" ]
      @sam_account_name = "dev"
      @user = @structural_class.new({
        :proxy_addresses => @proxy_addresses,
        :sam_account_name => @sam_account_name
      })
    end
    subject{ @user }

    should have_readers :dn
    should have_accessors :name, :system_flags, :display_name, :description
    should have_accessors :proxy_addresses, :sam_account_name

    should "return the proxy addresses set on it" do
      assert_equal @proxy_addresses, subject.proxy_addresses
      assert_equal @proxy_addresses, subject.fields[:proxyaddresses]
    end
    should "return the sam account name set on it" do
      assert_equal @sam_account_name, subject.sam_account_name
      assert_equal [ @sam_account_name ], subject.fields[:samaccountname]
    end
  end

  class SearchingTest < BaseTest
    desc "searching for an entry"
    setup do
      @user = @structural_class.find("joe test")
    end
    subject{ @user }

    should "find the user" do
      assert subject
    end
    should "set his name correctly" do
      assert_equal "joe test", subject.name
    end
  end

end
