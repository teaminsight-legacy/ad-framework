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
    should "contain all the attributes defined on the class" do
      @attrs.each do |attr|
        assert_includes attr, subject.attributes
      end
    end
  end
  
  class InstanceTest < TopTest
    desc "instance"
    setup do
      @top = @structural_class.new
    end
    subject{ @top }
    
    should have_readers :dn
    should have_accessors :name, :system_flags, :display_name, :description
  end

end
