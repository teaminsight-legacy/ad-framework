require 'ad-framework/exceptions'

module AD
  module Framework

    class Attribute
      attr_accessor :name, :ldap_name, :attribute_type

      def initialize(name)
        self.name = name
        definition = AD::Framework.defined_attributes.find(self.name)
        if !definition
          raise(AD::Framework::AttributeNotDefined, "There is no attribute defintion for #{name.inspect}.")
        end
        self.ldap_name = definition.ldap_name
        self.attribute_type = AD::Framework.defined_attribute_types.find(definition.type)
        if !self.attribute_type
          raise(*[
            AD::Framework::AttributeTypeNotDefined, 
            "There is no attribute type defined for #{definition.type.inspect}"
          ])
        end
      end

      def define_reader(klass)
        self.attribute_type.define_reader(self, klass)
      end
      def define_writer(klass)
        self.attribute_type.define_writer(self, klass)
      end

    end
  
  end
end
