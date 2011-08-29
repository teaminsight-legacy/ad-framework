module Factory
  extend Mocha::API

  class << self

    def attribute_definition(args = {})
      args[:name] ||= "test_attr"
      args[:ldap_name] ||= "testattr"
      args[:type] ||= "test_string"
      AD::Framework::Config::AttributeDefinition.new(args)
    end

    def mock_attribute(methods = {})
      attribute = mock()
      methods[:name] ||= "test_attr"
      methods[:ldap_name] ||= "testattr"
      methods[:attribute_type] ||= self.mock_attribute_type
      methods.each do |method, value|
        attribute.stubs(method).returns(value)
      end
      attribute
    end

    def mock_attribute_type(methods = {})
      attribute_type = mock()
      methods[:key] ||= "test_string"
      methods.each do |method, value|
        attribute_type.stubs(method).returns(value)
      end
      attribute_type
    end

    def structural_class(methods = {}, &block)
      block ||= ::Proc.new do
        ldap_name "testObjectClass"
      end
      structural_class = Class.new(AD::Framework::StructuralClass, &block)
      structural_class
    end

    def mock_structural_class_instance(methods = {})
      structural_class = mock()
      methods[:dn] ||= "CN=test object, DC=example, DC=com"
      methods[:fields] ||= {}
      methods.each do |method, value|
        structural_class.stubs(method).returns(value)
      end
      structural_class
    end

    def attribute_type(methods = {}, &block)
      block ||= ::Proc.new{}
      attribute_type = Class.new(AD::Framework::AttributeType, &block)
      attribute_type
    end

    def auxiliary_class(&block)
      block ||= ::Proc.new{}
      auxiliary_class = Module.new do
        include AD::Framework::AuxiliaryClass
      end
      auxiliary_class.class_eval(&block)
      auxiliary_class
    end

  end
end
