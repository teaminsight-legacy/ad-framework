require 'ad-framework/attribute'

module AD
  module Framework

    class Schema
      # TODO: test structural classes
      attr_accessor :ldap_name, :rdn, :attributes, :structural_classes, :auxiliary_classes
      attr_accessor :klass

      def initialize(klass)
        self.klass = klass

        self.rdn = :name
        self.auxiliary_classes = []

        if self.klass.is_a?(::Class) && self.klass.superclass.respond_to?(:schema)
          parent_schema = self.klass.superclass.schema
          self.attributes = parent_schema.attributes.dup
          # TODO: test that structural classes gets set here
          self.structural_classes = parent_schema.structural_classes.dup
          self.structural_classes << self.klass.superclass
        else
          self.attributes = Set.new
          self.structural_classes = [] # TODO: test that it defaults to an array
        end
      end

      # TODO: test that ldap name READER will use the ldap_prefix if set
      def ldap_name
        if @ldap_name
          [ AD::Framework.config.ldap_prefix,
            @ldap_name
          ].compact.join
        end
      end

      def treebase
        if @treebase && self.default_treebase && !(@treebase.include?(self.default_treebase))
          [ @treebase, self.default_treebase ].join(", ")
        else
          (@treebase || self.default_treebase)
        end
      end

      def treebase=(new_value)
        @treebase = new_value
      end

      def add_attributes(attribute_names)
        self.add_read_attributes(attribute_names)
        self.add_write_attributes(attribute_names)
      end

      def add_read_attributes(attribute_names)
        attribute_names.collect(&:to_sym).each do |name|
          AD::Framework::Attribute.new(name).define_reader(self.klass)
          self.attributes << name.to_sym
        end
      end

      def add_write_attributes(attribute_names)
        attribute_names.collect(&:to_sym).each do |name|
          AD::Framework::Attribute.new(name).define_writer(self.klass)
        end
      end

      # TODO: test this
      def object_classes
        [ self.structural_classes.to_a,
          self.klass,
          self.auxiliary_classes.to_a
        ].flatten.compact
      end

      def add_auxiliary_class(klass)
        self.auxiliary_classes << klass
        self.attributes.merge(klass.schema.attributes)
        self.auxiliary_classes.uniq!
      end

      def inspect
        attrs_display = [ :klass, :ldap_name, :rdn, :attributes ].collect do |attr|
          "#{attr}: #{self.send(attr).inspect}"
        end
        [ "#<#{self.class} ", attrs_display.join(", "), ">" ].join
      end

      protected

      def default_treebase
        AD::Framework.config.treebase
      end

    end

  end
end
