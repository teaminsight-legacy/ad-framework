module State
  class << self
    attr_accessor :current_framework_config, :current_ldap_config

    def preserve
      self.current_framework_config = AD::Framework.config.dup
      self.current_ldap_config = AD::LDAP.config.dup
      self.nullify
      load("test/support/schema/attribute_types.rb")
      load("test/support/schema/attributes.rb")
    end

    def restore
      self.nullify
      AD::LDAP.instance_variable_set("@config", self.current_ldap_config)
      AD::Framework.instance_variable_set("@config", self.current_framework_config)
    end

    protected

    def nullify
      AD::Framework.instance_variable_set("@config", nil)
      AD::LDAP.instance_variable_set("@logger", nil)
      AD::LDAP.instance_variable_set("@adapter", nil)
      AD::LDAP.instance_variable_set("@config", nil)
    end

  end
end
