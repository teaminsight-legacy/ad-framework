require 'assert'
require 'test/integration_helper'

class DefinedStructuralClassTest < Assert::Context
  desc "the defined structural class"

  class TopTest < DefinedStructuralClassTest
    desc "top"
    setup do
      @structural_class = AD::Top
    end
    subject{ @structural_class }

    should "be registered with AD::Framework's config" do
      assert_equal AD::Framework.config.structural_classes[subject.ldap_name], subject
    end

  end

  class SchemaTest < TopTest
    desc "schema"
    setup do
      @ldap_name = "top"
      @rdn = :name
      @treebase = [ "OU=Stuff", AD::Framework.config.treebase ].join(", ")
      @attrs = [ :name, :system_flags, :display_name, :description ]
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

  class InstanceTest < TopTest
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
      assert_equal [ @name ], subject.fields[:name]
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

  class UserTest < DefinedStructuralClassTest
    desc "user"
    setup do
      @structural_class = AD::User
    end
    subject{ @structural_class }
  end

  class SearchingTest < UserTest
    desc "searching for an entry"
    setup do
      @user = @structural_class.find("joe test")
    end
    subject{ @user }

    should "find the user" do
      assert subject
    end
  end

end
