module AD
  class Top < AD::Framework::StructuralClass

    ldap_name "top"
    rdn :name
    attributes :name, :system_flags, :display_name, :description

  end
end
AD::Framework.register_structural_class(AD::Top)

module AD
  class Container < AD::Top
    ldap_name "container"
  end
end
AD::Framework.register_structural_class(AD::Container)

module AD
  class Person < AD::Top
    ldap_name "person"
  end
end
AD::Framework.register_structural_class(AD::Person)

module AD
  class OrganizationalPerson < AD::Person
    ldap_name "organizationalPerson"
  end
end
AD::Framework.register_structural_class(AD::OrganizationalPerson)

module AD
  class User < AD::OrganizationalPerson
    include AD::SecurityPrincipal

    ldap_name "user"
    treebase "CN=Users, CN=AD Framework Tests"
    rdn :name
    attributes :proxy_addresses

  end
end
AD::Framework.register_structural_class(AD::User)