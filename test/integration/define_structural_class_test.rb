require 'assert'

class DefineStructuralClassTest < Assert::Context
  desc "defining a new structural class Something"
  setup do
    @structural_class = Something
  end
  subject{ @structural_class }

  should "be registered with AD::Framework's config" do
    assert_equal AD::Framework.config.structural_classes[subject.ldap_name], subject
  end

end
