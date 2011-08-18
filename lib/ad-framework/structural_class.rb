require 'ad-framework/patterns/has_schema'
require 'ad-framework/patterns/searchable'

module AD
  module Framework

    class StructuralClass
      include AD::Framework::Patterns::HasSchema
      include AD::Framework::Patterns::Searchable

      attr_accessor :meta_class, :errors, :fields

      def initialize(attributes = {})
        self.fields = (attributes.delete(:fields) || AD::Framework::Fields.new)

        self.attributes = attributes
        self.errors = {}
      end
      
      def connection
        self.class.connection
      end

      def inspect
        # attr_display = self.schema.attribute_needs[:read].collect do |name|
        #   "#{name}: #{self.send(name).inspect}"
        # end
        # [ "#<#{self.class} ", attr_display.join(", "), ">" ].join
        self.class.to_s
      end
      
      class << self
        
        def connection
          AD::Framework.connection
        end
        
      end

    end

  end
end
