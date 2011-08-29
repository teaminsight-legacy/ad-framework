require 'ad-framework/utilities/validator'

module AD
  module Framework
    module Patterns

      module Validations
        class << self

          def included(klass)
            klass.class_eval do
              include AD::Framework::Patterns::Validations::InstanceMethods
            end
          end

        end

        module InstanceMethods
          attr_accessor :errors
          
          def errors
            @errors ||= {}
          end

          [ :create, :update ].each do |name|

            define_method(name) do
              if self.valid?
                super
                true
              else
                false
              end
            end

          end

          def valid?
            validator = AD::Framework::Utilities::Validator.new(self)
            self.errors = validator.errors
            self.errors.empty?
          end

        end

      end

    end
  end
end
