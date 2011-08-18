require 'ad-ldap'

require 'ad-framework/config/mapping'
require 'ad-framework/config/attribute_definition'

module AD
  module Framework

    class Config
      attr_accessor :attributes, :attribute_types, :structural_classes

      def initialize
        self.mappings = AD::Framework::Config::Mapping.new

        self.attributes = AD::Framework::Config::Mapping.new
        self.attribute_types = AD::Framework::Config::Mapping.new
        self.structural_classes = AD::Framework::Config::Mapping.new
      end

      def ldap(&block)
        if block
          AD::LDAP.configure(&block)
        end
        AD::LDAP
      end
      alias :adapter :ldap

      def logger
        self.adapter.logger
      end
      def logger=(new_logger)
        self.adapter.config.logger = new_logger
      end

      [ :search_size_supported, :mappings, :run_commands ].each do |method|

        define_method(method) do
          self.adapter.config.send(method)
        end

        writer = "#{method}="
        define_method(writer) do |new_value|
          self.adapter.config.send(writer, new_value)
        end

      end

      def add_attribute(attribute)
        definition = AD::Framework::Config::AttributeDefinition.new(attribute)
        self.mappings.add(definition.name, definition.ldap_name)
        self.attributes.add(definition.name, definition)
      end
      def add_attribute_type(attribute_type)
        self.attribute_types.add(attribute_type.key, attribute_type)
      end
      def add_structural_class(structural_class)
        self.structural_classes.add(structural_class.ldap_name, structural_class)
      end

    end

  end
end
