module ActiveDirectory
  module Entry

    class Fields < Hash

      def initialize(ldap_entry)
        super()
        ldap_entry.each do |ldap_name, value|
          self[ldap_name.to_s] = value
        end
      end

      def build_entry
        name = self["objectclass"].last
        object_class = ActiveDirectory.config.object_classes[name]
        if !object_class
          raise(ActiveDirectory::NoObjectClassError, "An object class with the name #{name} is not defined")
        end
        object_class.new({ :fields => self })
      end

      def inspect
        max_key_length = self.keys.collect(&:size).max + 1
        display = self.collect do |(key, value)|
          key_label = "#{key}:".rjust(max_key_length, ' ')
          [ key_label, value.inspect ].join("  ")
        end
        "\n#{display.join("\n")}"
      end

    end

  end
end
