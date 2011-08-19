AD::Framework.register_attributes([
  { :name => "name",              :ldap_name => "name",                 :type => "string" },
  { :name => "system_flags",      :ldap_name => "systemflags",          :type => "integer" },
  { :name => "display_name",      :ldap_name => "displayname",          :type => "string" },
  { :name => "description",       :ldap_name => "description",          :type => "string" },
  { :name => "proxy_addresses",   :ldap_name => "proxyaddresses",       :type => "array" },
  { :name => "unix_member_of",    :ldap_name => "mssfu30posixmemberof", :type => "array" },
  { :name => "sam_account_name",  :ldap_name => "samaccountname",       :type => "string" },
])