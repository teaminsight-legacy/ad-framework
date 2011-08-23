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
    subject{ @structural_class }

    should "find the user from his dn with a call to #find" do
      name = "joe test"
      @user = subject.find("CN=#{name}, #{subject.schema.treebase}")

      assert @user
      assert_equal name, @user.name
    end
    should "find the user from his rdn with a call to #find" do
      name = "joe test"
      @user = subject.find(name)

      assert @user
      assert_equal name, @user.name
    end
    should "find the first matching user with a call to #first" do
      name = "joe test"
      @user = subject.first({ :name => name })

      assert @user
      assert_equal name, @user.name
    end
    should "find the first matching user using a ldap attribute with a call to #first" do
      user_name = "jtest"
      @user = subject.first({ :samaccountname => user_name })

      assert @user
      assert_equal user_name, @user.sam_account_name
    end
    should "return a collection of matching users with a call to #all" do
      name = "*test*"
      @users = subject.all({ :where => { :name => name }, :size => 5 })

      assert_not_empty @users
      @users.each do |user|
        assert_match user.name, /test/
      end
    end
    should "return a collection of matching users with complicated filters with a call to #all" do
      user_account_control = 545
      objectclass = "computer"
      @users = subject.all({
        :where => {
          :useraccountcontrol__ge => user_account_control,
          :objectclass__ne => objectclass,
        },
        :limit => 5
      })

      assert_not_empty @users
      @users.each do |user|
        assert user.fields["useraccountcontrol"].first.to_i >= user_account_control
      end
    end
    should "reload the user's fields and attributes with a call to #reload" do
      name = "joe test"
      new_name = "yo test"
      @user = subject.find(name)

      assert @user
      @user.name = new_name
      assert_equal new_name, @user.name
      @user.reload
      assert_not_equal new_name, @user.name
      assert_equal name, @user.name
    end
  end

end
