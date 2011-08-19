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
