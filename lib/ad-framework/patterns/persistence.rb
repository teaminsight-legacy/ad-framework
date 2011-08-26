# TODO: test this
module AD
  module Framework
    module Patterns

      module Persistence
        class << self

          def included(klass)
            klass.class_eval do
              extend AD::Framework::Patterns::Persistence::ClassMethods
              include AD::Framework::Patterns::Persistence::InstanceMethods
            end
          end

        end

        module InstanceMethods

          def save
            if self.new_entry?
              #TODO
            end
          end
          def create
            #run_validations!
            #run_callbacks do
              self.fields[:distinguishedname] = self.dn
              self.fields[:objectclass] = (self.schema.object_classes.collect do |object_class|
                object_class.schema.ldap_name
              end).compact
              self.connection.add({ :dn => self.dn, :attributes => self.fields.to_hash })
              self.reload
            #end
          end
          def update
            #TODO
          end
          
          def destroy
            #run_callbacks do
              self.connection.delete(self.dn)
            #end
          end

        end

        module ClassMethods

          def create(args = {})
            entry = self.new(args)
            entry.create
          end

        end

      end

    end
  end
end
