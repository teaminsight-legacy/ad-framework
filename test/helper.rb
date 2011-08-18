AD::Framework.register_attributes([
  { :name => "name", :ldap_name => "name", :type => "string" },
])

# TODO move to support file
class ExampleString < AD::Framework::AttributeType

  key "string"

end
AD::Framework.register_attribute_type(ExampleString)

# TODO move to support file
class Something < AD::Framework::StructuralClass

  ldap_name "something"

  rdn :name

  attributes :name

end
AD::Framework.register_structural_class(Something)