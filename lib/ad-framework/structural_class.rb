require 'ad-framework/fields'
require 'ad-framework/patterns/has_schema'
require 'ad-framework/patterns/persistence'
require 'ad-framework/patterns/searchable'

module AD
  module Framework

    class StructuralClass
      include AD::Framework::Patterns::HasSchema
      include AD::Framework::Patterns::Persistence # TODO test that this is included
      include AD::Framework::Patterns::Searchable

      attr_accessor :meta_class, :errors, :fields

      def initialize(attributes = {})
        self.meta_class = class << self; self; end

        self.fields = AD::Framework::Fields.new(attributes.delete(:fields) || {})
        # TODO: test this
        if (treebase = (attributes.delete(:treebase) || attributes.delete("treebase")))
          self.treebase = treebase
        end

        self.attributes = attributes
        self.errors = {}
      end

      # TODO: test this
      def treebase
        self.schema.treebase
      end
      def treebase=(new_value)
        self.schema.treebase = new_value
      end

      def connection
        self.class.connection
      end

      def inspect
        (attr_display = self.attributes.collect do |(name, value)|
          "#{name}: #{value.inspect}"
        end).sort
        [ "#<#{self.class} ", attr_display.join(", "), ">" ].join
      end

      class << self

        def connection
          AD::Framework.connection
        end

      end

    end

  end
end
