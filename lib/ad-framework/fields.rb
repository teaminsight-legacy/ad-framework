module AD
  module Framework

    class Fields < Hash

      def initialize(ldap_entry)
        super()
        (ldap_entry || {}).each do |ldap_name, value|
          self[ldap_name.to_s] = value
        end
      end

      def [](lookup)
        super(lookup.to_s)
      end
      def []=(lookup, object)
        super(lookup.to_s, object)
      end

      def build_entry
        if self["objectclass"]
          name = self["objectclass"].last
          structural_class = AD::Framework.defined_object_classes[name]
          if !structural_class
            raise(*[
              AD::Framework::StructuralClassNotDefined,
              "A structural class with the name #{name.inspect} is not defined"
            ])
          end
          structural_class.new({ :fields => self })
        end
      end

      def inspect
        max_key_length = (self.keys.collect(&:size).max || 0) + 1
        display = self.collect do |(key, value)|
          key_label = "#{key}:".rjust(max_key_length, ' ')
          [ key_label, value.inspect ].join("  ")
        end
        "\n#{display.join("\n")}"
      end

    end

  end
end
