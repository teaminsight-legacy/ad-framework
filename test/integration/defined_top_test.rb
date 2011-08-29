require 'assert'

class AD::Top

  class BaseTest < Assert::Context
    desc "top"
    setup do
      @structural_class = AD::Top
    end
    subject{ @structural_class }

    should "be registered with AD::Framework's config" do
      assert_equal AD::Framework.config.object_classes[subject.ldap_name], subject
    end
  end
  
  class SchemaTest < BaseTest
    desc "schema"
    setup do
      @ldap_name = "top"
      @rdn = :name
      @attrs = [ :name, :system_flags, :display_name, :description ]
      @schema = @structural_class.schema
    end
    subject{ @schema }

    should "store the ldap name defined on the class" do
      expected = [ AD::Framework.config.ldap_prefix, @ldap_name ].compact.join
      assert_equal expected, subject.ldap_name
    end
    should "store the rdn defined on the class" do
      assert_equal @rdn, subject.rdn
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
      @name = "joe test"
      @system_flags = 123456789
      @display_name = "Joe Test"
      @description = "A relevant description."
      @dn = [ "CN=#{@name}", @structural_class.treebase ].join(", ")
      @top = @structural_class.new({ :name => @name, :system_flags => @system_flags,
        :display_name => @display_name, :description => @description
      })
    end
    subject{ @top }

    should have_readers :dn
    should have_accessors :name, :system_flags, :display_name, :description

    should "return it's rdn with its treebase in it's dn" do
      assert_equal @dn, subject.dn
    end
    should "return the name set on it" do
      assert_equal @name, subject.name
      assert_equal [ @name ], subject.fields[:cn]
    end
    should "return the system_flags set on it" do
      assert_equal @system_flags, subject.system_flags
      assert_equal [ @system_flags.to_s ], subject.fields[:systemflags]
    end
    should "return the display_name set on it" do
      assert_equal @display_name, subject.display_name
      assert_equal [ @display_name ], subject.fields[:displayname]
    end
    should "return the description set on it" do
      assert_equal @description, subject.description
      assert_equal [ @description ], subject.fields[:description]
    end
  end
  
  class SearchingTest < BaseTest
    desc "searching for an entry"
    setup do
      @current = @structural_class.schema.treebase
      @structural_class.schema.treebase = nil
      @top = @structural_class.find("CN=joe test, #{AD::User.schema.treebase}")
    end
    subject{ @top }

    should "find the user" do
      assert subject
      assert_kind_of AD::User, subject
    end
    should "set his name correctly" do
      assert_equal "joe test", subject.name
    end
    
    teardown do
      @structural_class.schema.treebase = @current
    end
  end

end
