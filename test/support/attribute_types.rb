module AD
  class String < AD::Framework::AttributeType

    key "string"

    def value=(new_value)
      super(new_value ? new_value.to_s : new_value)
    end

  end
end
AD::Framework.register_attribute_type(AD::String)

module AD
  class Integer < AD::Framework::AttributeType

    key "integer"

    def value=(new_value)
      super(new_value ? new_value.to_i : new_value)
    end

  end
end
AD::Framework.register_attribute_type(AD::Integer)

module AD
  class Array < AD::Framework::AttributeType
    key "array"
    
    attr_accessor :item_class

    def initialize(object, attr_ldap_name)
      self.item_class = AD::String
      super
    end

    def value_from_field
      (self.object.fields[self.attr_ldap_name] || [])
    end

    def value
      self.get_items_values(@value)
    end

    def value=(new_value)
      values = [*new_value].compact.collect do |value|
        self.item_class.new(self.object, attr_ldap_name, value)
      end
      super(values)
    end

    def ldap_value=(new_value)
      super(self.get_items_values(new_value))
    end
    
    protected
    
    def get_items_values(items)
      [*items].compact.collect(&:value)
    end

  end
end

AD::Framework.register_attribute_type(AD::Array)

