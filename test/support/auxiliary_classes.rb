module AD
  module SecurityPrincipal
    include AD::Framework::AuxiliaryClass

    ldap_name "securityPrincipal"
    attributes :sam_account_name
    
  end
end
AD::Framework.register_auxiliary_class(AD::SecurityPrincipal)
