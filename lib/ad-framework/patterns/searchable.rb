module AD
  module Framework
    module Patterns

      module Searchable
        class << self

          def included(klass)
            klass.class_eval do
              extend AD::Framework::Patterns::Searchable::ClassMethods
            end
          end

        end

        module ClassMethods

          def find(dn)
            args = { :dn__eq => dn, :size => 1 }
            ldap_entry = self.connection.search(args).first
            fields = AD::Framework::Fields.new(ldap_entry)
            fields.build_entry
          end

        end

      end

    end
  end
end
