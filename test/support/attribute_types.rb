module AD
  class String < AD::Framework::AttributeType

    key "string"

  end
end
AD::Framework.register_attribute_type(AD::String)

module AD
  class Integer < AD::Framework::AttributeType

    key "integer"

  end
end
AD::Framework.register_attribute_type(AD::Integer)
