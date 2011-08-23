require 'ad-framework/auxiliary_class'
require 'ad-framework/exceptions'
require 'ad-framework/fields'
require 'ad-framework/structural_class'

module AD
  module Framework
    module Utilities

      class EntryBuilder
        attr_accessor :ldap_entry, :entry, :fields

        def initialize(ldap_entry, options = {})
          self.ldap_entry = ldap_entry
          self.fields = AD::Framework::Fields.new(self.ldap_entry || {})

          if options[:reload]
            self.entry = options[:reload]
            self.reload
          else
            self.build
          end
        end

        def reload
          self.entry.fields = self.fields
          self.entry.schema.attributes.each do |name|
            self.entry.send("#{name}_attribute_type").reset
          end
          self.link_auxiliary_classes
        end

        def build
          structure = self.classes_structure
          self.entry = structure[:structural_class].new({ :fields => self.fields })
          self.link_auxiliary_classes(structure)
        end

        protected

        def link_auxiliary_classes(structure = self.classes_structure)
          (structure[:auxiliary_classes] || []).each do |klass|
            if !self.entry.schema.auxiliary_classes.include?(klass)
              self.entry.meta_class.class_eval do
                include klass
              end
            end
            self.entry.schema.add_auxiliary_class(klass)
          end
        end

        def classes_structure
          (self.fields["objectclass"] || []).inject({}) do |processed, ldap_name|
            object_class = AD::Framework.defined_object_classes[ldap_name]
            if !object_class
              raise(*[
                AD::Framework::ObjectClassNotDefined,
                "An object class with the name #{ldap_name.inspect} is not defined"
              ])
            end
            if object_class.ancestors.include?(AD::Framework::StructuralClass)
              processed[:structural_class] = object_class
            elsif object_class.included_modules.include?(AD::Framework::AuxiliaryClass)
              processed[:auxiliary_classes] ||= []
              processed[:auxiliary_classes] << object_class
            end
            processed
          end
        end

      end

    end
  end
end
