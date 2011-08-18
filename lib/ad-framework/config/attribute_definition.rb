module AD
  module Framework
    class Config

      class AttributeDefinition
        attr_accessor :name, :ldap_name, :type

        def initialize(attributes)
          attributes.each do |key, value|
            self.send("#{key}=", value)
          end
        end

      end

    end
  end
end
