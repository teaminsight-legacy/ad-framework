require 'ad-framework/attribute'

module AD
  module Framework

    class Schema
      attr_accessor :ldap_name, :rdn, :attributes
      attr_accessor :klass, :entry

      def initialize(klass)
        self.klass = klass
      end

      def add_attributes(attribute_names)
        self.add_read_attributes(attribute_names)
        self.add_write_attributes(attribute_names)
      end

      def add_read_attributes(attribute_names)
        attribute_names.collect(&:to_sym).each do |name|
          AD::Framework::Attribute.new(name).define_reader(self.klass)
        end
      end

      def add_write_attributes(attribute_names)
        attribute_names.collect(&:to_sym).each do |name|
          AD::Framework::Attribute.new(name).define_writer(self.klass)
        end
      end

      def inspect
        attrs_display = [ "klass: #{self.klass.inspect}", "ldap_name: #{ldap_name.inspect}" ]
        [ "#<#{self.class} ", attrs_display.join(", "), ">" ].join
      end

    end

  end
end
