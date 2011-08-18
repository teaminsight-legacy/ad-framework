require 'assert'

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
      @dn = [ "DN=#{@name}", @structural_class.treebase ].join(", ")
      @top = @structural_class.new({ :name => @name })
    end
    subject{ @top }
    
    should have_readers :dn
    should have_accessors :name, :system_flags, :display_name, :description
    
    should "return it's rdn with its treebase in it's dn" do
      assert_equal(@dn, subject.dn)
    end
  end

end
