require 'ad-framework/schema'

module AD
  module Framework
    module Patterns

      module HasSchema
        class << self

          def included(klass)
            klass.class_eval do
              extend AD::Framework::Patterns::HasSchema::ClassMethods
              include AD::Framework::Patterns::HasSchema::InstanceMethods
            end
          end

        end

        module InstanceMethods

          def schema
            @schema ||= self.class.schema.dup
          end

          def dn
            dn = self.fields[:distinguishedname] || self.fields[:dn]
            dn ||= [ "CN=#{self.send(self.schema.rdn)}", self.schema.treebase ].join(", ")
          end

          def attributes
            self.schema.attributes.inject({}) do |attrs, name|
              attrs.merge({ name.to_sym => self.send(name.to_sym) })
            end
          end
          def attributes=(new_attributes)
            new_attributes.each do |name, value|
              if self.schema.attributes.include?(name)
                self.send("#{name}=", value)
              end
            end
          end

        end

        module ClassMethods

          def schema
            @schema ||= AD::Framework::Schema.new(self)
          end

          def ldap_name(name = nil)
            (self.schema.ldap_name = name) if name
            self.schema.ldap_name
          end

          def treebase(value = nil)
            (self.schema.treebase = value) if value
            self.schema.treebase
          end

          def rdn(name = nil)
            (self.schema.rdn = name) if name
            self.schema.rdn
          end

          def attributes(*attribute_names)
            self.schema.add_attributes(attribute_names)
          end

          def read_attributes(*attribute_names)
            self.schema.add_read_attributes(attribute_names)
          end

          def write_attributes(*attribute_names)
            self.schema.add_write_attributes(attribute_names)
          end

        end

      end

    end
  end
end
