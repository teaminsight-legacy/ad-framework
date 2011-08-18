require 'ad-framework/config'
require 'ad-framework/attribute_type'
require 'ad-framework/structural_class'

module AD
  module Framework
    class << self

      def configure
        if block_given?
          yield self.config
        end
        self.config
      end

      def config
        @config ||= AD::Framework::Config.new
      end

      def connection
        self.config.adapter
      end

      def defined_attributes
        self.config.attributes
      end
      def register_attributes(attributes)
        attributes.each do |attribute|
          self.config.add_attribute(attribute)
        end
      end

      def defined_attribute_types
        self.config.attribute_types
      end
      def register_attribute_type(attribute_type)
        self.config.add_attribute_type(attribute_type)
      end

      def register_structural_class(structural_class)
        self.config.add_structural_class(structural_class)
      end

    end
  end
end
